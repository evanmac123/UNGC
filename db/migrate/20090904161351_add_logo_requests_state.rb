class AddLogoRequestsState < ActiveRecord::Migration
  def self.up
    add_column :logo_requests, :state, :string
  end

  def self.down
    remove_column :logo_requests, :state
  end
end
