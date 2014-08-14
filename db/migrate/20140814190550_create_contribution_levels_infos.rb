class CreateContributionLevelsInfos < ActiveRecord::Migration
  def change
    create_table :contribution_levels_infos do |t|
      t.references :local_network
      t.string :level_description
      t.string :amount_description

      t.timestamps
    end
    add_index :contribution_levels_infos, :local_network_id
  end
end
