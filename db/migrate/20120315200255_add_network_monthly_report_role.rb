class AddNetworkMonthlyReportRole < ActiveRecord::Migration
  def self.up
    say "Adding Network Monthly Report Role"
    Role.create :name => 'Monthly Report Recipient', :description => "Receives Monthly Participant Reports by email", :old_id => 16
  end

  def self.down
    say "Deleting Network Monthly Report Role"
    role = Role.find_by_name('Monthly Report Recipient')
    role.destroy if Role.exists?(role)
  end
end