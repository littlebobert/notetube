class AddHtmlToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :memo_html, :text
  end
end
