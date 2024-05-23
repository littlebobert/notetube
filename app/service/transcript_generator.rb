require 'youtube-captions'
require 'json'

# Method 1: Use `youtube-captions` gem, which crawls the page looking for a caption URL

class TranscriptGenerator
  def initialize(url)
    @url = url
  end

  def self.beautify_transcript(ugly_transcript)
    api_key = ENV["OPEN_AI_API_KEY"]
    url = "https://api.openai.com/v1/chat/completions"

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{api_key}"
    }

    prompt = "Reformat the following transcript into paragraphs and add proper capitalization without changing the original words:\n\n#{ugly_transcript}"
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

  def call
    video = YoutubeCaptions::Video.new(id: @url)
    p video.info
    captions = video.captions(lang: "en")
    p video.captions
    result = ""
    captions.each do |caption|
      result = result + " " + caption["__content__"] unless caption["__content__"].nil?
    end

    return result
  end
end
