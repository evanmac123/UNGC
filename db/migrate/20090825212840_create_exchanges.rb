class CreateExchanges < ActiveRecord::Migration
  def self.up
    create_table :exchanges do |t|
      t.string :code
      t.string :name
      t.string :secondary_code
      t.string :terciary_code
      t.integer :country_id

      t.timestamps
    end
  end

  def self.down
    drop_table :exchanges
  end
end
