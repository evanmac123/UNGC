class AddMediaToEvents < ActiveRecord::Migration
  def change
    add_column :events, :media_description, :text
  end
end
