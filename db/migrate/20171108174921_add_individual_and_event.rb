class AddIndividualAndEvent < ActiveRecord::Migration
  def change
    add_reference :due_diligence_reviews, :event, index: true
    add_column :due_diligence_reviews, :individual_subject, :string, limit: 100
  end
end
