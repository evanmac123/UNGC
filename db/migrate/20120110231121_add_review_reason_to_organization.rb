class AddReviewReasonToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :review_reason, :string
  end

  def self.down
    remove_column :organizations, :review_reason
  end
end
