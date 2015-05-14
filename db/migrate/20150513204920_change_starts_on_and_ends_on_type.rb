class ChangeStartsOnAndEndsOnType < ActiveRecord::Migration
  def up
    change_column :events, :starts_on, :datetime
    change_column :events, :ends_on, :datetime
  end

  def down
    change_column :events, :starts_on, :date
    change_column :events, :ends_on, :date
  end
end
