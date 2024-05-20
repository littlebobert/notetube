class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :video_url
      t.text :transcript
      t.text :memo
      t.boolean :is_bookmarked
      t.references :user, null: false, foreign_key: true
      t.string :title

      t.timestamps
    end
  end
end
