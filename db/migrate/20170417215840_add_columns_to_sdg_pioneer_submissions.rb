class AddColumnsToSdgPioneerSubmissions < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_submissions, :company_success, :text
    add_column :sdg_pioneer_submissions, :innovative_sdgs, :text
    add_column :sdg_pioneer_submissions, :ten_principles, :text
    add_column :sdg_pioneer_submissions, :awareness_and_mobilize, :text
  end
end
