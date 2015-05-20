class RemoveUrlsFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :urls
  end
end
