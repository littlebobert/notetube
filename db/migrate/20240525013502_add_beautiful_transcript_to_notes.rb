class AddBeautifulTranscriptToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :beautiful_transcript, :text
  end
end
