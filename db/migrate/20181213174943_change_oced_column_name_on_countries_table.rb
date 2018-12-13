class ChangeOcedColumnNameOnCountriesTable < ActiveRecord::Migration
  def change
    rename_column :countries, :oced, :oecd 
  end
end
