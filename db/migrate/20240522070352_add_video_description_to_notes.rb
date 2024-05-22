class AddVideoDescriptionToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :video_description, :string
  end
end
