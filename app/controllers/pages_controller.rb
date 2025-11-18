require 'net/http'
require 'json'
require_relative '../services/prompt_manager'
require_relative '../services/grading_service'

class PagesController < ApplicationController
  before_action :check_session, only: [:chat, :generate_response, :submit_diagnosis, :grading, :back_to_chat]

  # Constants for retry logic
  MAX_RETRIES = 3
  INITIAL_BACKOFF = 1.0
  MAX_BACKOFF = 16.0

  class RetryableAPIError < StandardError; end

  def generate_response
    message = params[:message]
    patient_id = session[:patient_id]
    
    if message.blank?
      render json: { error: "Message cannot be empty" }, status: :unprocessable_entity
      return
    end

    # Build conversation history
    messages = session[:messages] || []
    
    # Format for Gemini API using clearer roles
    conversation = messages.map do |msg|
      role = msg[:role] == 'user' ? '醫師' : '病人'
      "#{role}: #{msg[:content]}"
    end.join("\n")

    # Load prompt based on patient specialty
    system_prompt = PromptManager.combined_prompt(patient_id)

    # Add a final, strong instruction to constrain the AI's response
    final_instruction = "\n\n你是「病人」。請只用「病人」的身份和語氣回覆上面「醫師」的最後一句話。你的回覆必須簡短，只能有1-3句話。絕對不要自己產生「醫師」的回覆或任何角色標籤。"

    # Instruction to explicitly mark the doctor's latest message
    doctor_latest_message_prefix = "\n\n以下是醫師的最新提問，請您作為病人進行回覆：\n"

    # Add system prompt to first message
    if messages.empty?
      full_prompt = "#{system_prompt}#{doctor_latest_message_prefix}醫師: #{message}#{final_instruction}"
    else
      full_prompt = "#{conversation}#{doctor_latest_message_prefix}醫師: #{message}#{final_instruction}"
    end

    begin
      response = call_gemini_api(full_prompt)
      render json: { success: true, patient_response: response }
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def entry
    # Display entry page with username input and patient selection
  end

  def create_session
    username = params[:username]
    patient_id = params[:patient_id]

    if username.blank? || patient_id.blank?
      redirect_to entry_page_path, alert: "Please enter username and select a patient"
      return
    end

    session[:username] = username
    session[:patient_id] = patient_id
    session[:messages] = []
    session[:conversation_started] = false

    redirect_to chat_page_path
  end

  def chat
    @username = session[:username]
    @patient_id = session[:patient_id]
    @messages = session[:messages] || []
  end

  def send_message
    Rails.logger.info "--- PagesController#send_message ---"
    Rails.logger.info "Raw params: #{params.to_unsafe_h.inspect}"

    message_text = params[:message]
    patient_response = params[:patient_response]

    Rails.logger.info "Received message_text: '#{message_text}'"
    Rails.logger.info "Received patient_response: '#{patient_response}'"

    if message_text.blank?
      render json: { error: "Message cannot be empty" }, status: :unprocessable_entity
      return
    end

    session[:messages] ||= []
    session[:messages] << { role: "user", content: message_text }

    if patient_response.present?
      session[:messages] << { role: "patient", content: patient_response }
    end

    Rails.logger.info "Current session[:messages] count: #{session[:messages].count}"
    Rails.logger.info "--- END PagesController#send_message ---"

    render json: { success: true }
  end

  def submit_diagnosis
    session[:diagnosis] = params[:diagnosis]
    session[:differential_diagnosis] = params[:differential_diagnosis]
    session[:treatment_plan] = params[:treatment_plan]
    redirect_to grading_page_path
  end

  def grading
    @username = session[:username]
    @patient_id = session[:patient_id]
    @messages = session[:messages] || []
    
    @diagnosis = session[:diagnosis] || "未提交"
    @differential_diagnosis = session[:differential_diagnosis] || "未提交"
    @treatment_plan = session[:treatment_plan] || "未提交"
    
    # Call the grading service with the new structured diagnosis
    @grading_results = GradingService.new(
      messages: @messages, 
      diagnosis: @diagnosis,
      differential_diagnosis: @differential_diagnosis,
      treatment_plan: @treatment_plan
    ).perform
  end

  def back_to_chat
    redirect_to chat_page_path
  end

  private

  def call_gemini_api(prompt)
    retries = 0
    backoff = INITIAL_BACKOFF

    begin
      api_key = ENV['GEMINI_API_KEY']
      url = URI("https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=#{api_key}")
      
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      
      request = Net::HTTP::Post.new(url)
      request['Content-Type'] = 'application/json'
      
      body = {
        contents: [{ parts: [{ text: prompt }] }]
      }
      
      request.body = JSON.generate(body)
      
      response = http.request(request)
      
      if response.code.to_i >= 500
        raise RetryableAPIError, "Received #{response.code} response from API."
      end
      
      unless response.is_a?(Net::HTTPSuccess)
        raise "Gemini API error: #{response.code} - #{response.body}"
      end
      
      result = JSON.parse(response.body)
      result.dig('candidates', 0, 'content', 'parts', 0, 'text') || "I couldn't generate a response."

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
        raise "The service is currently unavailable after multiple retries. Please try again later."
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
            raise "The service timed out after multiple retries. Please try again later."
        end
    end
  end

  def check_session
    redirect_to entry_page_path, alert: "Please start a new session" if session[:username].blank?
  end
end
