class AddFinancialContactRole < ActiveRecord::Migration
  def self.up
    say "Adding Financial Contact"
    Role.create :name => 'Financial Contact'
  end

  def self.down
    say "Deleting Financial Contact"
    role = Role.find_by_name('Financial Contact')
    role.destroy
  end
end