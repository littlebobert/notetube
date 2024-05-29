class QuizGenerator
  def initialize(note)
    @note = note
  end

  def call
    if @note.quiz_json.present?
      return @note.quiz_json
    end
	  api_key = ENV["OPEN_AI_API_KEY"]
	  url = "https://api.openai.com/v1/chat/completions"
    
	  headers = {
		  'Content-Type' => 'application/json',
		  'Authorization' => "Bearer #{api_key}"
	  }
    
	  prompt = "We are building a website for generating lecture notes from a YouTube lecture video transcript. Please generate a 5 question multiple choice quiz with answers from the following transcript as JSON: #{@note.transcript}"
	
	  body = {
	  model: 'gpt-4o',
	  response_format: { "type": "json_object" },
	  messages: [
      { "role": "user", "content": prompt }
	  ],
	  max_tokens: 4096
	  }.to_json
	  
	  response = HTTP.headers(headers).post(url, body: body)
	  response_data = JSON.parse(response.body.to_s)
	  final_json = response_data["choices"].first["message"]["content"]
	  @note.quiz_json = final_json
	  @note.save
	  return final_json
  end
end
