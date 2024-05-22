class AddThumbnailUrlToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :thumbnail_url, :string
  end
end
