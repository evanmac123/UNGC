class RenameCommunicationOnProgressContactName < ActiveRecord::Migration
  def change
    rename_column :communication_on_progresses, :contact_name, :contact_info
  end
end
