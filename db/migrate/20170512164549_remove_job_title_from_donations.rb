class RemoveJobTitleFromDonations < ActiveRecord::Migration
  def change
    remove_column :donations, :job_title, :string
  end
end
