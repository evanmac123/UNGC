class CreateCommunicationOnProgressesPrinciples < ActiveRecord::Migration
  def self.up
    create_table :communication_on_progresses_principles, :id => false do |t|
      t.integer :communication_on_progress_id
      t.integer :principle_id
    end
  end

  def self.down
    drop_table :communication_on_progresses_principles
  end
end
