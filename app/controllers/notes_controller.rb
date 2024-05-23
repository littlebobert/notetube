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
  puts "<<< before code conversion"
  code_matches = markdown.scan(/([^`]*)`{0,3}([^`]*)`{0,3}([^`]*)/m)
  html = ""
  puts "code_matches: #{code_matches}"
  num_code_blocks = 0
  code_matches.each do |code_match|
    puts "code_match: #{code_match}"
    if code_match[0].present?
      puts "before code: #{code_match[0]}"
      html << transform_formulas(code_match[0])
    end
    if code_match[1].present?
      num_code_blocks += 1
      puts "code block: #{code_match[1]}"
      html << "<div class='text-end code-wrapper'><div onclick=\"copyElement(document.getElementById('code-block-#{num_code_blocks}'));\" class='copy-code-button text-justify-right'><span data-controller='tooltip' data-bs-toggle='tooltip' data-bs-position='bottom' title='Copy'><i class='fa-solid fa-copy'></i> Copy<span></div><pre id='code-block-#{num_code_blocks}' class='code-block'>#{code_match[1]}</pre></div>"
    end
    if code_match[2].present?
      puts "after code: #{code_match[2]}"
      html << transform_formulas(code_match[2])
    end
  end
  puts "html: #{html}"

  return html
end

class NotesController < ApplicationController
  def create
    video_url = params[:v]
    note = Note.where(video_url: video_url).first
    if note.nil?
      id = extract_video_id(video_url)
      note = Note.new(video_url: video_url, user: current_user)
      authorize note
      video_details = YoutubeService.get_video_details(video_url)
      if video_details
        note.title = video_details[:title]
        note.thumbnail_url = video_details[:thumbnail]
        note.video_description = video_details[:description]
        note.view_count = video_details[:view_count]
        note.channel_name = video_details[:channel_title]
        note.published_at = video_details[:published_at]
      end
      transcript = TranscriptGenerator.new(video_url).call
      note.transcript = transcript
      note.video_id = id
      memo = NoteGenerator.new(transcript).call
      note.memo = memo
      # fix me: use save here, not save!
      note.save!
    else
      authorize note
    end
    redirect_to note_path(note, show: "notes")
  end

  def show
    @note = Note.find(params[:id])
    authorize @note
    @video_id = extract_video_id(@note.video_url)
    @memo = transform_bracketed_text(@note.memo)
  end

  def update
    @note = Note.find(params[:id])
    authorize @note
    @note.update(note_params)
    @note.save
    redirect_to note_path(@note)
  end

  def index
    @notes = policy_scope(Note)
  end

  private

  def note_params
    params.require(:note).permit(:is_bookmarked)
  end
end
