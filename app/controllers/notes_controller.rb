require 'github/markup'
# require 'youtube-captions'

class NotesController < ApplicationController
  def create
    video_url = params[:v]
    note = Note.where(video_url: video_url).first
    puts TranscriptGenerator.new(video_url).call
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
