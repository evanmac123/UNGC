class CreateCommunications < ActiveRecord::Migration
  def self.up
    create_table :communications do |t|
      t.integer :local_network_id
      t.string  :title
      t.string  :communication_type
      t.date    :date
    end
  end

  def self.down
    drop_table :communications
  end
end
