class AddRegionIndexOnCountries < ActiveRecord::Migration
  def change
    add_index :countries, :region
  end
end
