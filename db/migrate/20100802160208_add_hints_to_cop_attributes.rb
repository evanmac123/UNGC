class AddHintsToCopAttributes < ActiveRecord::Migration
  def self.up
    add_column :cop_attributes, :hint, :string
  end

  def self.down
    remove_column :cop_attributes, :hint
  end
end
