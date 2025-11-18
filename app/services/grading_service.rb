require 'net/http'
require 'json'
require 'concurrent'

class GradingService
  PROMPT_FILES = {
    history_of_present_illness: 'config/prompts/grading/1_history_of_present_illness.txt',
    past_history: 'config/prompts/grading/2_past_history.txt',
    empathy_and_communication: 'config/prompts/grading/3_empathy_and_communication.txt',
    clinical_reasoning: 'config/prompts/grading/4_clinical_reasoning.txt',
    overall_assessment: 'config/prompts/grading/5_overall_assessment.txt'
  }.freeze

  # Constants for retry logic
  MAX_RETRIES = 3
  INITIAL_BACKOFF = 1.0 # seconds
  MAX_BACKOFF = 16.0 # seconds

  class RetryableAPIError < StandardError; end

  def initialize(messages:, diagnosis:, differential_diagnosis:, treatment_plan:)
    @messages = messages
    @diagnosis = diagnosis
    @differential_diagnosis = differential_diagnosis
    @treatment_plan = treatment_plan
    @transcript = self.class.format_transcript(messages)
  end

  def perform
    # Define scoring agents and the summary agent
    scoring_agents = PROMPT_FILES.slice(
      :history_of_present_illness, 
      :past_history, 
      :empathy_and_communication, 
      :clinical_reasoning
    )
    summary_agent_key = :overall_assessment
    summary_agent_file = PROMPT_FILES[summary_agent_key]

    # Run scoring agents in parallel
    pool = Concurrent::FixedThreadPool.new(scoring_agents.size)
    
    scoring_futures = scoring_agents.map do |key, file_path|
      Concurrent::Future.execute(executor: pool) do
        prompt = load_and_prepare_prompt(file_path)
        response = call_gemini_api(prompt)
        parse_response(key, response)
      end
    end

    # Collect results from scoring agents
    results = scoring_futures.map(&:value).reduce({}, :merge)
    
    pool.shutdown
    pool.wait_for_termination

    # Calculate the average score from the valid, non-error scores
    scores = results.values.map { |res| res[:score] if res && res[:score].is_a?(Integer) }.compact
    average_score = scores.empty? ? 0 : (scores.sum.to_f / scores.size).round

    # Run the summary agent to get textual feedback
    summary_prompt = load_and_prepare_prompt(summary_agent_file)
    summary_response = call_gemini_api(summary_prompt)
    summary_result = parse_response(summary_agent_key, summary_response)

    # Combine calculated score and textual feedback
    overall_assessment_text = summary_result[summary_agent_key] || {}
    
    final_overall_assessment = {
      score: average_score,
      justification: overall_assessment_text[:justification] || "Could not generate summary justification.",
      positive_feedback: overall_assessment_text[:positive_feedback] || "Could not generate positive feedback.",
      improvement_suggestion: overall_assessment_text[:improvement_suggestion] || "Could not generate improvement suggestions."
    }

    # Add the final overall assessment to the main results hash
    results[summary_agent_key] = final_overall_assessment

    results
  end

  def self.format_transcript(messages)
    messages.map do |msg|
      role = msg[:role] == 'user' ? 'Doctor' : 'Patient'
      "#{role}: #{msg[:content]}"
    end.join("\n")
  end

  private

  def load_and_prepare_prompt(file_path)
    prompt_template = File.read(Rails.root.join(file_path))
    prompt_template.gsub('{{TRANSCRIPT}}', @transcript)
                   .gsub('{{DIAGNOSIS}}', @diagnosis.to_s)
                   .gsub('{{DIFFERENTIAL_DIAGNOSIS}}', @differential_diagnosis.to_s)
                   .gsub('{{TREATMENT_PLAN}}', @treatment_plan.to_s)
  end

  def call_gemini_api(prompt)
    retries = 0
    backoff = INITIAL_BACKOFF
    response = nil

    begin
      api_key = ENV['GEMINI_API_KEY']
      url = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=#{api_key}")
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'
      
      body = {
        contents: [{ parts: [{ text: prompt }] }],
        generation_config: {
          response_mime_type: "application/json",
          temperature: 0.2
        }
      }
      
      request.body = JSON.generate(body)
      
      response = http.request(request)

      # Raise a custom error for 5xx status codes to trigger a retry
      if response.code.to_i >= 500
        raise RetryableAPIError, "Received #{response.code} response from API."
      end

      response

    rescue RetryableAPIError => e
      if retries < MAX_RETRIES
        retries += 1
        sleep_time = backoff + rand(0..1.0)
        Rails.logger.warn "Gemini API error: #{e.message}. Retrying in #{sleep_time.round(2)} seconds... (Attempt #{retries}/#{MAX_RETRIES})"
        sleep sleep_time
        backoff = [backoff * 2, MAX_BACKOFF].min
        retry
      else
        Rails.logger.error "Gemini API error: Max retries reached. Last error: #{e.message}"
        # Return the last failed response to be handled by the parser
        response
      end
    rescue Net::OpenTimeout, Net::ReadTimeout => e
        if retries < MAX_RETRIES
            retries += 1
            sleep_time = backoff + rand(0..1.0)
            Rails.logger.warn "Gemini API timeout: #{e.message}. Retrying in #{sleep_time.round(2)} seconds... (Attempt #{retries}/#{MAX_RETRIES})"
            sleep sleep_time
            backoff = [backoff * 2, MAX_BACKOFF].min
            retry
        else
            Rails.logger.error "Gemini API timeout: Max retries reached. Last error: #{e.message}"
            # Return a mock 503 response if we never got a response
            Net::HTTPServiceUnavailable.new('1.1', '503', 'Service Unavailable after max retries')
        end
    end
  end

  def parse_response(key, response)
    if response.is_a?(Net::HTTPSuccess)
      begin
        parsed_json = JSON.parse(response.body)
        json_string = parsed_json.dig('candidates', 0, 'content', 'parts', 0, 'text')
        { key => JSON.parse(json_string, symbolize_names: true) }
      rescue JSON::ParserError, TypeError => e
        Rails.logger.error "Failed to parse JSON for grading agent '#{key}': #{e.message}"
        Rails.logger.error "Raw response part: #{json_string.inspect}"
        { key => { error: "Failed to parse evaluation response.", score: 0 } }
      end
    else
      Rails.logger.error "Gemini API error for grading agent '#{key}': #{response.code} - #{response.body}"
      { key => { error: "API request failed with status #{response.code}.", score: 0 } }
    end
  end
end
