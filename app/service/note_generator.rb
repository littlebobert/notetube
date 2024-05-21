require 'youtube-captions'
require 'json'

def fetch_notes(transcript)
  api_key = ENV["OPEN_AI_API_KEY"]
  url = "https://api.openai.com/v1/chat/completions"

  headers = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{api_key}"
  }

  prompt = "We're building a website for generating lecture notes from a YouTube lecture video transcript. Please generate lecture notes from the following transcript: #{transcript}"

  # puts "OpenAI prompt: #{prompt}"

  # Set up the request body
  body = {
    model: 'gpt-4o',
    messages: [
      { "role": "user", "content": prompt }
    ],
    max_tokens: 4096
  }.to_json

  response = HTTP.headers(headers).post(url, body: body)
  response_data = JSON.parse(response.body.to_s)
  puts response_data
  final = response_data["choices"].first["message"]["content"]
  puts "output: #{final}"
  return final
end

class NoteGenerator
  def initialize(transcript)
    @transcript = transcript
  end

  def call
    fetch_notes(@transcript)
  end
end
