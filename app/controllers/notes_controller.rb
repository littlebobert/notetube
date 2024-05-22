require 'github/markup'
# require 'youtube-captions'

def transform_bracketed_text(markdown)
  # Define a regex pattern to match text not inside brackets
  pattern = /([^\[]+)(?:\[[^\]]*?\])*/m
  # Use gsub to find and transform all non-bracketed text
  markdown = markdown.gsub(pattern) do |match|
    GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, match)
  end

  # Now iterate over all bracketed text
  pattern = /\[(.*?)\]/m
  markdown = markdown.gsub(pattern) do |match|
    inner_text = match[1..-2]
    transformed_text = "$$\\begin{gather}" + inner_text + "\\\\ \\notag \\end{gather}$$"
    transformed_text
  end

  return markdown
end

class NotesController < ApplicationController
  def create
    video_url = params[:v]
    note = Note.where(video_url: video_url).first
    puts TranscriptGenerator.new(video_url).call
    if note.nil?
      note = Note.new(video_url: video_url, user: current_user)
      transcript = TranscriptGenerator.new(video_url).call
      memo = NoteGenerator.new(transcript).call
      note.memo = transform_bracketed_text(memo)
      # fix me: use save here, not save!
      note.save!
    end
    redirect_to note_path(note)
  end

  def show
    @note = Note.find(params[:id])
  end
end
