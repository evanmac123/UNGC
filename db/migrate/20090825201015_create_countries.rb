class CreateCountries < ActiveRecord::Migration
  def self.up
    create_table :countries do |t|
      t.string :code
      t.string :name
      t.string :region
      t.integer :network_type
      t.string :manager

      t.timestamps
    end
  end

  def self.down
    drop_table :countries
  end
end
