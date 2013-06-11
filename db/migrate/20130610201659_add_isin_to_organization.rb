class AddIsinToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :isin, :string
  end

  def self.down
    remove_column :organizations, :isin
  end
end
