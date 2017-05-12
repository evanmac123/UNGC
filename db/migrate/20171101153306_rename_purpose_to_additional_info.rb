class RenamePurposeToAdditionalInfo < ActiveRecord::Migration
  def change
    rename_column :due_diligence_reviews, :purpose, :additional_information
    remove_index :due_diligence_reviews, :additional_information
    change_column :due_diligence_reviews, :additional_information,
                  :string, limit: 512
  end
end
