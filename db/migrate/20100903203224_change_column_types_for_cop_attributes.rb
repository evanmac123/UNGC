class ChangeColumnTypesForCopAttributes < ActiveRecord::Migration
  def self.up
    change_column :cop_attributes, :hint, :text, :null => false
  end

  def self.down
    change_column :cop_attributes, :hint, :string, :null => false
  end
end
