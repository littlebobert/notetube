require 'youtube-captions'
require 'json'

# Method 1: Use `youtube-captions` gem, which crawls the page looking for a caption URL

class TranscriptGenerator
  def initialize(url)
    @url = url
  end

  def call
    video = YoutubeCaptions::Video.new(id: @url)
    # captions = video.captions(lang: "en")
    captions = video.captions(lang: "en")
    result = ""
    captions.each do |caption|
      result = result + caption["__content__"] unless caption["__content__"].nil?
    end
    return result
  end
end
