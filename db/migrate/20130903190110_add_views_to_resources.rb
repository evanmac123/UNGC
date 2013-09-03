class AddViewsToResources < ActiveRecord::Migration
  def change
    add_column :resources, :views, :integer, default: 0
  end
end
