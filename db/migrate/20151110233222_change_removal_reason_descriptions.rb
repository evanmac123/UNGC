class ChangeRemovalReasonDescriptions < ActiveRecord::Migration
  def up
    RemovalReason.transaction do
      RemovalReason.find(4).update(description: 'Expelled due to failure to communicate progress')
      RemovalReason.find(5).update(description: 'Expelled due to failure to engage in dialogue')
      RemovalReason.find(1).update(description: 'Other')
    end
  end

  def down
    RemovalReason.transaction do
      RemovalReason.find(4).update(description: 'Failure to communicate progress')
      RemovalReason.find(5).update(description: 'Failure to engage in dialogue')
      RemovalReason.find(1).update(description: 'Not applicable')
    end
  end
end
