class AddVideoIdToNote < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :video_id, :string
  end
end
