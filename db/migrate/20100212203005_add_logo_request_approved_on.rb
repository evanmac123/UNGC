class AddLogoRequestApprovedOn < ActiveRecord::Migration
  def self.up
    add_column :logo_requests, :approved_on, :date
  end

  def self.down
    remove_column :logo_requests, :approved_on, :date
  end
end
