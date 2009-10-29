class AddDescriptionToCommunicationOnProgress < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :description, :text
  end

  def self.down
    remove_column :communication_on_progresses, :description
  end
end
