class AddLevelOfParticipationToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :level_of_participation, :integer
  end
end
