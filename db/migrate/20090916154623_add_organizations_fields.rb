class AddOrganizationsFields < ActiveRecord::Migration
  def self.up
    add_column :organizations, :exchange_id, :integer
    add_column :organizations, :listing_status_id, :integer
    add_column :organizations, :is_ft_500, :boolean
  end

  def self.down
    remove_column :organizations, :exchange_id
    remove_column :organizations, :listing_status_id
    remove_column :organizations, :is_ft_500
  end
end
