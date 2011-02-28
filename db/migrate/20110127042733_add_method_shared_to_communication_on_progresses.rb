class AddMethodSharedToCommunicationOnProgresses < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :method_shared, :string
  end

  def self.down
    remove_column :communication_on_progresses, :method_shared
  end
end