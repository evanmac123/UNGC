class AddScreeningAttributesToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :is_landmine, :boolean
    add_column :organizations, :is_tobacco, :boolean
  end
end
