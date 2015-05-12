class ChangeDefaultForContainerContentType < ActiveRecord::Migration
  def up
    change_column :redesign_containers, :content_type, :integer, :default => 1
    Redesign::Container.update_all content_type: 1
  end

  def down
    change_column :redesign_containers, :content_type, :integer, :default => 0
  end
end
