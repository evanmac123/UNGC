class AddIsBiologicalWeaponsToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :is_biological_weapons, :boolean
  end
end
