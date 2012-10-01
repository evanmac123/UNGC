class RemoveLegacyColumnsFromLogoRequests < ActiveRecord::Migration
  def self.up
    remove_column :logo_requests, :requested_on
    remove_column :logo_requests, :status_changed_on
    remove_column :logo_requests, :status
  end

  def self.down
    add_column :logo_requests, :status, :string
    add_column :logo_requests, :status_changed_on, :date
    add_column :logo_requests, :requested_on, :date
  end
end
