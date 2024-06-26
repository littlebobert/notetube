require 'github/markup'
# require 'youtube-captions'

def extract_video_id(url)
  # Define the regular expression pattern for YouTube video IDs
  regex = /(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})/

  # Match the regular expression with the provided URL
  match = url.match(regex)

  # If a match is found, return the video ID, otherwise return nil
  match ? match[1] : nil
end

def transform_formulas(markdown)
  # Define a regex pattern to match text not inside brackets (first group) and text inside brackets (second group):
  pattern = /([^\[]+)(\[[^\]]*?\])*/m
  matches = markdown.scan(pattern)
  result = ""
  matches.each do |match|
    not_a_formula = match[0]
    # Hack to get rid of the \ that ChatGPT is adding before all opening brackets for formulas:
    not_a_formula = not_a_formula.gsub("\\", "")
    html = GitHub::Markup.render_s(GitHub::Markups::MARKUP_MARKDOWN, not_a_formula)
    result << html
    formula_with_brackets = match[1]
    if formula_with_brackets
      formula = formula_with_brackets[1..-2]
      formula_with_math_jax_directives = "$$\\begin{gather}" + formula + "\\\\ \\notag \\end{gather}$$"
      result << formula_with_math_jax_directives
    end
  end
  return result
end

def transform_bracketed_text(markdown)
  code_matches = markdown.scan(/([^`]*)`{0,3}([^`]*)`{0,3}([^`]*)/m)
  html = ""
  num_code_blocks = 0
  code_matches.each do |code_match|
    if code_match[0].present?
      html << transform_formulas(code_match[0])
    end
    if code_match[1].present?
      num_code_blocks += 1
      escaped = CGI::escapeHTML(code_match[1])
      code_block = render_to_string partial: 'shared/code', locals: { num_code_blocks: num_code_blocks, code: escaped }
      html << code_block
    end
    if code_match[2].present?
      html << transform_formulas(code_match[2])
    end
  end
  return html
end

class NotesController < ApplicationController
  def create
    video_url = params[:v]
    if video_url == "fashion"
      authorize Note.new
      redirect_to "https://www.youtube.com/watch?v=dQw4w9WgXcQ", allow_other_host: true
      return
    end
    video_id = extract_video_id(video_url)
    if !video_id
      authorize Note.new
      redirect_to root_path, alert: "Invalid YouTube URL."
      return
    end
    note = Note.where(video_id: video_id).first
    if note.nil?
      note = Note.new(video_id: video_id, user: current_user)
      authorize note
      video_details = YoutubeService.get_video_details(video_url)
      if video_details
        note.title = video_details[:title]
        note.thumbnail_url = video_details[:thumbnail]
        note.video_description = video_details[:description]
        note.view_count = video_details[:view_count]
        note.channel_name = video_details[:channel_title]
        note.published_at = video_details[:published_at]
      else
        redirect_to root_path, alert: "Invalid YouTube URL."
        return
      end

      begin
        transcript = TranscriptGenerator.new(video_url).call
      rescue Exceptions::NoCaptions
        flash[:error] = "No captions available."
        redirect_to root_path
        return
      end
      note.transcript = transcript
      note.video_id = video_id
      note.video_url = video_url
      # fix me: use save here, not save!
      note.save!
    else
      authorize note
    end
    redirect_to note_path(note)
  end

  def show
    @note = Note.find(params[:id])
    authorize @note
    @video_id = @note.video_id
  end

  def update
    @note = Note.find(params[:id])
    authorize @note
    respond_to do |format|
      if @note.update(note_params)
        format.html { redirect_to @note, notice: 'Note was successfully updated.' }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('bookmark-button', partial: 'bookmark_button', locals: { note: @note }) }
        format.json { render json: { status: 'success' } }
      else
        format.html { render :edit }
        format.turbo_stream { render turbo_stream: turbo_stream.replace('bookmark-button', partial: 'bookmark_button', locals: { note: @note }) }
        format.json { render json: { status: 'failure', errors: note.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def index
    @notes = policy_scope(Note)

    if params[:tags].present?
      tags = params[:tags].split(',')
      @notes = @notes.tagged_with(tags, any: true)
    end

    if params[:sort_by] == "tag"
      @notes = @notes.joins(:tags).order('tags.name ASC')
    end

  end

  def beautiful_transcript
    @note = Note.find(params[:id])
    authorize @note
    render plain: TranscriptGenerator::beautify_transcript(@note)
  end

  def raw_transcript
    @note = Note.find(params[:id])
    authorize @note
    result = TranscriptGenerator::timestamped_transcript_json(@note)
    render plain: result
  end

  def raw_notes
    @note = Note.find(params[:id])
    authorize @note
    if @note.memo_html.present?
      render plain: @note.memo_html
      return
    end
    memo = NoteGenerator.new(@note.transcript).call
    @note.memo = memo
    @note.memo_html = transform_bracketed_text(memo)
    @note.save
    render plain: @note.memo_html
  end

  def create_tag
    @note = Note.find(params[:note_id])
    @note.tag_list.add(params[:tag_list].split(", "))
    authorize @note
    if @note.save
      redirect_to note_path(@note), notice: 'Added to your library'
    else
      render :show, status: :unprocessable_entity
    end
  end

  def quiz
    @note = Note.find(params[:id])
    authorize @note
    quiz_json = QuizGenerator.new(@note).call
    render plain: quiz_json
  end

  private

  def note_params
    params.require(:note).permit(:is_bookmarked, :memo_html, :tag_list)
  end
end
