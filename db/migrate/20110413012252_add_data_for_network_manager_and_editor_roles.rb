class AddDataForNetworkManagerAndEditorRoles < ActiveRecord::Migration

  def self.up
    Role.create :name => 'Local Network Manager', :description => 'Manages Local Networks within a geographic region.', :old_id => 14, :position => 18
    Role.create :name => 'Website Editor', :description => 'Authorized to review and publish content on the Global Compact website.', :old_id => 15, :position => 19
  end

  def self.down
    Role.delete_all("old_id IN (14,15)")
  end

end
