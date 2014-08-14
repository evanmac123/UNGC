class CreateContributionLevels < ActiveRecord::Migration
  def change
    create_table :contribution_levels do |t|
      t.references :contribution_levels_info, null: false
      t.string :description, null: false
      t.string :amount, null: false

      t.timestamps
    end
    add_index :contribution_levels, :contribution_levels_info_id
  end
end
