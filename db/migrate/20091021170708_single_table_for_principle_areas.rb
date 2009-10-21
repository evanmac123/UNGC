class SingleTableForPrincipleAreas < ActiveRecord::Migration
  def self.up
    add_column :principles, :type, :string
  end

  def self.down
    remove_column :principles, :type
  end
end
