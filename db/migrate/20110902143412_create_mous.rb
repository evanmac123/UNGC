class CreateMous < ActiveRecord::Migration
  def self.up
    create_table :mous do |t|
      t.integer :local_network_id
      t.date :year
      t.timestamps
    end
  end

  def self.down
    drop_table :mous
  end
end
