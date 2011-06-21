class SetDifferentationColumnValuesForAllCops < ActiveRecord::Migration

  def self.up
    say "Setting differentiation level for all COPs. This may take a few minutes..."
    CommunicationOnProgress.approved.each do |cop|
      cop.type = 'advanced' if cop.additional_questions == true
      cop.save
    end

  end

  def self.down
    CommunicationOnProgress.approved.each do |cop|
      cop.differentiation = nil
    end
    
  end
end
