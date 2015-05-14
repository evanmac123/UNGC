class RenameStartsOnAndEndsOn < ActiveRecord::Migration
  def change
    rename_column :events, :starts_on, :starts_at
    rename_column :events, :ends_on, :ends_at
  end
end
