class AddViewsToResourceLinks < ActiveRecord::Migration
  def change
    add_column :resource_links, :views, :integer, default: 0
  end
end
