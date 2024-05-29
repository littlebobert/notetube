require 'youtube-captions'
require 'json'

module Exceptions
  class NoCaptions < StandardError; end
end

# Method 1: Use `youtube-captions` gem, which crawls the page looking for a caption URL

class TranscriptGenerator
  def initialize(url)
    @url = url
  end

  def self.beautify_transcript(note)
    if note.beautiful_transcript.present?
      return note.beautiful_transcript
    end
    api_key = ENV["OPEN_AI_API_KEY"]
    url = "https://api.openai.com/v1/chat/completions"

    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{api_key}"
    }
    
    timestamped_transcript_as_json = TranscriptGenerator::timestamped_transcript_json(note)
    prompt = "Reformat the following JSON transcript into paragraphs and add proper capitalization without changing the original words. Send back paragraphs as JSON in the form {\"paragraphs\":[{\"paragraph\":\"paragraph one\",\"start_time\":0,\"duration\":30},{\"paragraph\":\"paragraph two\",\"start_time\":30,\"duration\":10}]}, etc. Here is the transcript:\n\n#{timestamped_transcript_as_json}"

    # Set up the request body
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
    final = response_data["choices"].first["message"]["content"]
    note.beautiful_transcript = final
    note.save
    return final
  end

  def call
    begin
      video = YoutubeCaptions::Video.new(id: @url)
    rescue
      raise Exceptions::NoCaptions
    end
    captions = video.captions(lang: "en")
    result = ""
    captions.each do |caption|
      result = result + " " + caption["__content__"] unless caption["__content__"].nil?
    end

    return result
  end
  
  def self.timestamped_transcript_json(note)
    if note.transcript_json.present?
      return note.transcript_json
    end
    video = YoutubeCaptions::Video.new(id: "https://www.youtube.com/watch?v=#{note.video_id}")
    captions = video.captions(lang: "en")
    result = []
    captions.each do |caption|
      result << { 
        :caption => caption["__content__"].gsub(/^\p{Zs}*/, "").gsub(/\p{Zs}*$/, ""),
        :start_time => caption["start"],
        :duration => caption["dur"]
      }
    end
    json = result.to_json
    note.transcript_json = json
    note.save
    return json
  end
end
