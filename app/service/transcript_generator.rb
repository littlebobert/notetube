require 'youtube-captions'
require 'json'

# Method 1: Use `youtube-captions` gem, which crawls the page looking for a caption URL

class TranscriptGenerator
  def initialize(url)
    @url = url
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
