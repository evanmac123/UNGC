class AddDeclinationReason < ActiveRecord::Migration
  def change
    add_column :due_diligence_reviews, :declination_reason, :integer
  end
end
