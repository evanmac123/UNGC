class ExtendSizeAdditionalInfo < ActiveRecord::Migration
  def up
    change_column :due_diligence_reviews, :additional_information, :text
  end

  def down
    change_column :due_diligence_reviews, :additional_information, :string, limit: 512
  end
end
