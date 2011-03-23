class AddRejoinedOnToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :rejoined_on, :date
    say "Setting rejoined_on to date of last COP"
    Organization.participants.active.all.each do |o|
      if o.delisted_on.present? && o.removal_reason == RemovalReason.delisted
        if o.communication_on_progresses.approved.count > 0
          latest_cop = o.communication_on_progresses.approved.first.updated_at.try(:to_date)
          o.update_attribute :rejoined_on, latest_cop
        end
      end
    end
    
  end

  def self.down
    remove_column :organizations, :rejoined_on
  end
end
