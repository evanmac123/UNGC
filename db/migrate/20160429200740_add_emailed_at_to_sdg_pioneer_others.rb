class AddEmailedAtToSdgPioneerOthers < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_others, :emailed_at, :datetime
  end
end
