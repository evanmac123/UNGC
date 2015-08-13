class RenameRedesignPayloadsToPayloads < ActiveRecord::Migration
  def change
    rename_table :redesign_payloads, :payloads
  end
end
