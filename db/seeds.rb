# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'google/apis/youtube_v3'

Note.destroy_all
User.destroy_all

user = User.create!(email: "test@gmail.com", password: "password")
Note.create!(
  title: "sean's video",
  video_url: "https://www.youtube.com/watch?v=cwtpLIWylAw",
  memo: "
  ### Overview
  - **Topic:** Week 1 of CS50
  - **Focus:** Introduction to the C programming language
  - **Context:** Transitioning from Scratch to C, understanding basic concepts and tools in C
  ",
  transcript: "
  00:00	[INTRIGUING MUSIC]  DAVID MALAN: All right, so this is CS50.\
\
  01:06	And this is week 1, zero index, so to speak. And it's not every day that you can say that \
  you've learned a new language, but today is that day. Today, we explore a more traditional and \
  older language called C. And rest assured that even if what you're about to see-- no pun \
  intended-- looks very cryptic, very unusual, particularly if you're among those less comfortable, \
  cling to the ideas from last week, week zero, wherein we talked about some of those \
  fundamentals of functions and loops and conditionals, all of which are coming back today.\
  \
  01:35	Indeed, whereas last week, and with problem set 0, we focused on learning how to \
  program with Scratch, which, again, you might have played with as a younger student days\
  back. Today, we focus on C instead. But along the way, we're going to focus, as always, \
  frankly, on learning how to solve problems. But among the goals for today and really on an \
  entire class like this is just to give you week after week all the more tools for your toolkit, so to \
  speak, via which to do exactly that.\
  \
  02:01	So for instance today, we'll learn how to solve problems all the more so with functions, \
  as per last week. We'll do the same with variables. We'll do the same with conditionals, with \
  loops, and with more. But we'll also learn at the end of today's class really how not to solve \
  problems.\
  ",
  is_bookmarked: false,
  user: user
)

puts "created #{User.count} users and #{Note.count} notes"

# Replace with your API key
API_KEY = ENV["YOUTUBE_API_KEY"]
puts API_KEY

# Initialize the YouTube API client
youtube = Google::Apis::YoutubeV3::YouTubeService.new
youtube.key = API_KEY

# Replace with the video ID for which you want to get captions
VIDEO_ID = '3gb-ZkVRemQ'

# List the caption tracks
begin
  response = youtube.list_captions('id,snippet', VIDEO_ID)

  response.items.each do |caption|
    puts "Caption ID: #{caption.id}, Language: #{caption.snippet.language}, Name: #{caption.snippet.name}"
    puts caption.snippet.text
  end
rescue Google::Apis::Error => e
  puts "An error occurred: #{e}"
end
