class ExtendPayloadJsonDataLength < ActiveRecord::Migration
  def change
    change_column :payloads, :json_data, :text, null: false, limit: 4294967295
  end
end
