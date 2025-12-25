# frozen_string_literal: true

require 'json'
require 'net/http'
require 'uri'

# GradingSchemeDesigner generates a customized grading scheme using Google File Search (RAG).
# It calls the Gemini generateContent API with a File Search tool configured via GRADING_SCHEME_STORE_NAME.
# The service returns a parsed hash and a pre-grouped representation ready for rendering.
class GradingSchemeDesigner
  DEFAULT_MODEL = ENV.fetch('GRADING_SCHEME_MODEL', 'gemini-2.5-flash-lite').freeze
  FILE_SEARCH_URL = "https://generativelanguage.googleapis.com/v1beta/models/%{model}:generateContent?key=%{key}"
  CATEGORY_ORDER = [
    'appropriate introduction',
    'presenting complaint',
    'other relevant history',
    'communication skills',
    'diagnosis',
    'management',
    'other'
  ].freeze

  SystemInstruction = <<~PROMPT.freeze
    你是一位專業的醫學教育專家，擔任 "Grading Scheme Designer"。
    你的任務是依據給定的病例，產生 OSCE 評分表，並盡量參考已知病例庫的結構。

    要求：
    - 必須產生 JSON 格式，頂層應包含: disease, chief_complaint, checklist_items[], scoring_summary, key_references。
    - 每個 checklist_items 需包含: id, category, item, full_score, required, guidance。
    - category 建議使用: Appropriate Introduction, Presenting Complaint, Other Relevant History, Communication Skills, Diagnosis, Management。
    - full_score 為整數，required 為布林值，guidance 提供具體指引。
    - 所有內容（包含疾病名稱、項目描述、指引等）請務必使用「繁體中文」撰寫。
    - 請以審慎且可機讀的 JSON 回覆。
  PROMPT

  ParsedScheme = Struct.new(:raw, :grouped_items, :error, keyword_init: true)

  def initialize(store_name: ENV['GRADING_SCHEME_STORE_NAME'], model: DEFAULT_MODEL)
    @store_name = store_name
    @model = model
  end

  # Generate a grading scheme using File Search. Returns ParsedScheme.
  def generate(patient_case_details:)
    return ParsedScheme.new(error: 'GRADING_SCHEME_STORE_NAME 未設定') unless @store_name.present?

    response_text = call_genai(patient_case_details)
    return ParsedScheme.new(error: response_text) if response_text.is_a?(String) && response_text.start_with?('ERROR:')

    parsed = parse_json(response_text)
    grouped = group_items(parsed)

    ParsedScheme.new(raw: parsed, grouped_items: grouped, error: grouped.nil? ? '未能取得有效的評分表資料' : nil)
  rescue StandardError => e
    ParsedScheme.new(error: "產生 RAG 評分表時發生錯誤：#{e.message}")
  end

  private

  def call_genai(patient_case_details)
    api_key = ENV['GOOGLE_API_KEY'] || ENV['GEMINI_API_KEY']
    return 'ERROR: 缺少 GOOGLE_API_KEY / GEMINI_API_KEY' if api_key.blank?

    url = URI(format(FILE_SEARCH_URL, model: @model, key: api_key))

    # Use camelCase for Google API JSON keys
    body = {
      'contents' => [
        { 'role' => 'user', 'parts' => [{ 'text' => user_prompt(patient_case_details) }] }
      ],
      'systemInstruction' => { 'parts' => [{ 'text' => SystemInstruction }] },
      'tools' => [
        {
          'fileSearch' => {
            'fileSearchStoreNames' => [@store_name]
          }
        }
      ],
      'generationConfig' => {
        'responseMimeType' => 'application/json',
        'temperature' => 0.2
      }
    }

    Rails.logger.info "GradingSchemeDesigner Request: #{JSON.pretty_generate(body)}"

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(body)

    response = http.request(request)
    
    Rails.logger.info "GradingSchemeDesigner Response Code: #{response.code}"
    Rails.logger.info "GradingSchemeDesigner Response Body: #{response.body.force_encoding('UTF-8')}"

    unless response.is_a?(Net::HTTPSuccess)
      return "ERROR: File Search API 失敗 #{response.code} - #{response.body}" if response.code.to_i >= 400
    end

    parsed = JSON.parse(response.body)
    
    # Extract text from all parts
    candidates = parsed.dig('candidates', 0, 'content', 'parts')
    return 'ERROR: 無法取得模型回應' unless candidates

    full_text = candidates.map { |part| part['text'] }.join("\n")
    full_text
  rescue JSON::ParserError => e
    "ERROR: 回應解析失敗 #{e.message}"
  rescue StandardError => e
    "ERROR: 呼叫 File Search 失敗 #{e.message}"
  end

  def user_prompt(patient_case_details)
    <<~PROMPT
      以下為新的病例資訊，請參考 File Search 找到的類似案例格式後，輸出客製化的評分表（JSON）。

      #{patient_case_details}
    PROMPT
  end

  def parse_json(text)
    JSON.parse(text)
  rescue JSON::ParserError
    cleaned = extract_json_block(text)
    cleaned ? JSON.parse(cleaned) : { 'raw_response' => text, 'status' => 'raw_text' }
  end

  def extract_json_block(text)
    return if text.blank?

    stripped = text.strip
    fenced = stripped.match(/```(?:json)?\s*(\{.*?\})\s*```/m)
    return fenced[1] if fenced

    brace_index = stripped.index('{')
    brace_index ? stripped[brace_index..] : nil
  end

  def group_items(scheme)
    checklist = scheme.is_a?(Hash) ? scheme['checklist_items'] : nil
    return nil unless checklist.is_a?(Array)

    buckets = CATEGORY_ORDER.index_with { [] }

    checklist.each do |item|
      category = (item['category'] || 'Other').to_s.downcase
      key = CATEGORY_ORDER.find { |c| category.include?(c) } || 'other'

      buckets[key] << {
        id: item['id'] || buckets[key].size + 1,
        name: item['item'] || '未提供項目',
        guidance: item['guidance'] || '-',
        full_score: item['full_score'] || 1,
        required: item['required'].nil? ? false : item['required']
      }
    end

    # Remove empty categories but keep order
    buckets.select { |_, items| items.any? }
  end
end
