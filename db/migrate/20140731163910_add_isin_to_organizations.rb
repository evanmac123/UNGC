class AddIsinToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :isin, :string
  end
end
