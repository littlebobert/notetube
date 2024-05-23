class AddStatisticsToNotes < ActiveRecord::Migration[7.1]
  def change
    add_column :notes, :view_count, :integer
    add_column :notes, :channel_name, :string
    add_column :notes, :published_at, :datetime
  end
end
