class AddTranscriptJsonToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :transcript_json, :text
  end
end
