class AddTimestampsToSdgPioneerTables < ActiveRecord::Migration
  def change
    change_table(:sdg_pioneer_individuals) { |t| t.timestamps }
    change_table(:sdg_pioneer_others) { |t| t.timestamps }
  end
end
