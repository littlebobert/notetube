class AddQuizJsonToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :quiz_json, :text
  end
end
