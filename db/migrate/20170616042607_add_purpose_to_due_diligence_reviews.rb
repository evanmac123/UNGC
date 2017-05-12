class AddPurposeToDueDiligenceReviews < ActiveRecord::Migration
  def change
    add_column :due_diligence_reviews, :purpose, :string
    add_index :due_diligence_reviews, :purpose
  end
end
