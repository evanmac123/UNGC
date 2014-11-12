class AddRegionalCenterIdToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :regional_center_id, :integer
  end
end
