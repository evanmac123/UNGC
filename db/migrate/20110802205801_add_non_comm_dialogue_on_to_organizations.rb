class AddNonCommDialogueOnToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :non_comm_dialogue_on, :date
  end

  def self.down
    remove_column :organizations, :non_comm_dialogue_on
  end
end
