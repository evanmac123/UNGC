class AddOrganizationNameMatchedToSdgPioneerIndividuals < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_individuals, :organization_name_matched, :boolean, default: false, null: false
  end
end
