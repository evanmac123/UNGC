class AddColumnsToSdgPioneerOthers < ActiveRecord::Migration
  def change
    add_column :sdg_pioneer_others, :is_participant, :boolean
    add_column :sdg_pioneer_others, :organization_name, :string
    add_column :sdg_pioneer_others, :organization_name_matched, :boolean
  end
end
