class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      t.text :description
      t.date :starts_on
      t.date :ends_on
      t.text :location
      t.integer :country_id
      t.text :urls
      t.integer :created_by_id
      t.integer :updated_by_id

      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end
