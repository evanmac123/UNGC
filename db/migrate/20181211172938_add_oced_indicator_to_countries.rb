class AddOcedIndicatorToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :oced, :boolean, default: false
  end
end
