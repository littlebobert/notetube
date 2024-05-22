class ChangeVideoDescriptionTypeInNotes < ActiveRecord::Migration[7.1]
  def change
    change_column :notes, :video_description, :text
  end
end
