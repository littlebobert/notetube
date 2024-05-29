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
      response = youtube.list_videos('snippet,statistics', id: video_id)
      video = response.items.first
      if video
        {
          title: video.snippet.title,
          description: video.snippet.description,
          thumbnail: video.snippet.thumbnails.high.url,
          view_count: video.statistics.view_count,
          channel_title: video.snippet.channel_title,
          published_at: video.snippet.published_at
        }
      else
        nil
      end
    rescue Google::Apis::ClientError => e
      Rails.logger.error("YouTube API error: #{e.message}")
      nil
    end
  end
  
  def self.comments(video_id)
    youtube = Google::Apis::YoutubeV3::YouTubeService.new
    youtube.key = YOUTUBE_API_KEY
    comments =  youtube.list_comment_threads(
      'snippet',
      video_id: video_id,
      max_results: 5,
      page_token: nil
    )
    results = []
    comments.items.each do |item|
      blob = {}
      blob["author"] = item.snippet.top_level_comment.snippet.author_display_name
      blob["comment"] = item.snippet.top_level_comment.snippet.text_display
      results << blob
    end
    return results.to_json
  end

end
