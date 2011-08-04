class CreateAwardsTable < ActiveRecord::Migration
  def self.up
    create_table :awards do |t|
      t.integer  :local_network_id
      t.string   :title
      t.text     :description
      t.string   :type
      t.date     :date
      t.timestamps
    end
  end

  def self.down
    drop_table :awards
  end
end
