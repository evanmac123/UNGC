class RemoveUnusedCopColumns < ActiveRecord::Migration
  def self.up
    remove_column :communication_on_progresses, :identifier
    remove_column :communication_on_progresses, :related_document
    remove_column :communication_on_progresses, :facilitator
    remove_column :communication_on_progresses, :added_on
    remove_column :communication_on_progresses, :modified_on
    remove_column :communication_on_progresses, :status
    remove_column :communication_on_progresses, :start_year
    remove_column :communication_on_progresses, :start_month
    remove_column :communication_on_progresses, :end_year
    remove_column :communication_on_progresses, :end_month
    remove_column :communication_on_progresses, :include_ceo_letter
    remove_column :communication_on_progresses, :support_statement_signee
    remove_column :communication_on_progresses, :parent_company_cop
    remove_column :communication_on_progresses, :parent_cop_cover_subsidiary
    remove_column :communication_on_progresses, :support_statement_explain_benefits
    remove_column :communication_on_progresses, :missing_principle_explained
    remove_column :communication_on_progresses, :is_shared_with_stakeholders
    remove_column :communication_on_progresses, :replied_to
    remove_column :communication_on_progresses, :reviewer_id
    remove_column :communication_on_progresses, :url1
    remove_column :communication_on_progresses, :url2
    remove_column :communication_on_progresses, :url3
  end

  def self.down
    add_column :communication_on_progresses, :identifier, :string
    add_column :communication_on_progresses, :related_document, :string
    add_column :communication_on_progresses, :facilitator, :string
    add_column :communication_on_progresses, :added_on, :date
    add_column :communication_on_progresses, :modified_on, :date
    add_column :communication_on_progresses, :status, :integer
    add_column :communication_on_progresses, :start_year, :integer
    add_column :communication_on_progresses, :start_month, :integer
    add_column :communication_on_progresses, :end_year, :integer
    add_column :communication_on_progresses, :end_month, :integer
    add_column :communication_on_progresses, :include_ceo_letter, :boolean
    add_column :communication_on_progresses, :support_statement_signee, :string
    add_column :communication_on_progresses, :parent_company_cop, :boolean
    add_column :communication_on_progresses, :parent_cop_cover_subsidiary, :boolean
    add_column :communication_on_progresses, :support_statement_explain_benefits, :boolean
    add_column :communication_on_progresses, :missing_principle_explained, :boolean
    add_column :communication_on_progresses, :is_shared_with_stakeholders, :boolean
    add_column :communication_on_progresses, :replied_to, :boolean
    add_column :communication_on_progresses, :reviewer_id, :integer
    add_column :communication_on_progresses, :url1, :string
    add_column :communication_on_progresses, :url2, :string
    add_column :communication_on_progresses, :url3, :string
  end
end