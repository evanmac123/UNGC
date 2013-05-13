class InsertGeneralToPrinciples < ActiveRecord::Migration
  def self.up
    Principle.create :name => "Global Compact"
  end

  def self.down
    Principle.delete_all :name => "Global Compact"
  end
end
