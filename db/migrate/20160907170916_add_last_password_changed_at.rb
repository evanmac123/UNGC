class AddLastPasswordChangedAt < ActiveRecord::Migration
  def change
    add_column :contacts, :last_password_changed_at, :datetime
  end
end
