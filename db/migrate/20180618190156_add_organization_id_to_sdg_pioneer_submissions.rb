class AddOrganizationIdToSdgPioneerSubmissions < ActiveRecord::Migration
  def change
    add_reference :sdg_pioneer_submissions, :organization, index: true, foreign_key: true
    change_column :sdg_pioneer_submissions, :organization_name_matched, :boolean, default: true
  end
end
