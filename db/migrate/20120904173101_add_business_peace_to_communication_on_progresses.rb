class AddBusinessPeaceToCommunicationOnProgresses < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :references_business_peace, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :references_business_peace
  end
end
