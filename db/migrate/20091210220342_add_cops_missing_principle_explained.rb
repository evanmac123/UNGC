class AddCopsMissingPrincipleExplained < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :missing_principle_explained, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :missing_principle_explained
  end
end
