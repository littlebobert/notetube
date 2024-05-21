require 'github/markup'
# require 'youtube-captions'

class NotesController < ApplicationController
  def create
    video_url = params[:v]
    note = Note.where(video_url: video_url).first
    if note.nil?
      note = Note.new(video_url: video_url, user: current_user)
      transcript = TranscriptGenerator.new(video_url).call
      memo = NoteGenerator.new(transcript).call
      note.memo = memo
      note.save!
    end
    redirect_to note_path(note)
  end

  def show
    @note = Note.find(params[:id])
  end
end

require 'json'

# Method 2: use youtube-dl (yt-dlp actually)
require 'open3'
require 'tempfile'
require "http"
require "json"

def download_notes(video_url)
  # Try downloading the manually uploaded English captions first
  command = "yt-dlp --write-sub --sub-lang en --skip-download --output '%(id)s.%(ext)s' #{video_url}"

  stdout, stderr, status = Open3.capture3(command)

  if status.success?
    vtt_file = Dir.glob("*.en.vtt").first
    if vtt_file
      puts "Manually uploaded English captions downloaded successfully"
      result = clean_vtt(vtt_file)
      File.delete(vtt_file) if File.exist?(vtt_file)
      return result
    end
  end

  # If the manually uploaded captions are not available, try downloading the auto-generated English captions
  puts "Manually uploaded English captions not found. Trying to download auto-generated captions..."
  command = "yt-dlp --write-auto-sub --sub-lang en --skip-download --output '%(id)s.%(ext)s' #{video_url}"

  stdout, stderr, status = Open3.capture3(command)

  if status.success?
    vtt_file = Dir.glob("*.en.vtt").first
    if vtt_file
      puts "Auto-generated English captions downloaded successfully"
      result = clean_vtt(vtt_file)
      File.delete(vtt_file) if File.exist?(vtt_file)
      return result
    else
      puts "No English captions available for this video."
    end
  else
    puts "Error downloading captions: #{stderr}"
  end
end

def clean_vtt(vtt_file)
  captions = ""
  previous_line = ""

  File.foreach(vtt_file) do |line|
    # Skip lines with timestamps or alignment information
    next if line =~ /^\d{2}:\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}:\d{2}\.\d{3}.*$/ || line.strip.empty? || line.strip == 'WEBVTT' || line.start_with?("Kind:") || line.start_with?("Language:")

    # Remove any HTML tags and strip whitespace
    cleaned_line = line.gsub(/<[^>]+>/, '').strip

    # Skip if the cleaned line is empty or is a repetition of the previous line
    next if cleaned_line.empty? || cleaned_line == previous_line

    captions << cleaned_line + "\n"
    previous_line = cleaned_line
  end

  puts captions
  fetch_notes(captions)
end
