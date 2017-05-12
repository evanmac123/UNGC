class AddWithReservationToDueDiligence < ActiveRecord::Migration
  def change
    add_column :due_diligence_reviews, :with_reservation, :boolean
  end
end
