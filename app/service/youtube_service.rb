# app/services/youtube_service.rb
require 'google/apis/youtube_v3'

class YoutubeService
  YOUTUBE_API_KEY = ENV["YOUTUBE_API_KEY"]

  def self.get_video_details(url)
    video_id = extract_video_id(url)
    return nil unless video_id

    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = YOUTUBE_API_KEY
    begin
      response = youtube.list_videos('snippet', id: video_id)
      video = response.items.first
      if video
        {
          title: video.snippet.title,
          description: video.snippet.description,
          thumbnail: video.snippet.thumbnails.high.url
        }
      else
        nil
      end
    rescue Google::Apis::ClientError => e
      Rails.logger.error("YouTube API error: #{e.message}")
      nil
    end
  end


end
