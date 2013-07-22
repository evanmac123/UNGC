class AddReferencesWaterMandateToCommunicationOnProgress < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :references_water_mandate, :boolean
  end
end
