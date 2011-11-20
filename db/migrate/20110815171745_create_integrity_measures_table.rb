class CreateIntegrityMeasuresTable < ActiveRecord::Migration
  def self.up
    create_table :integrity_measures do |t|
      t.integer :local_network_id
      t.string  :title
      t.string  :policy_type
      t.text    :description
      t.date    :date
    end
  end

  def self.down
    drop_table :integrity_measures
  end
end
