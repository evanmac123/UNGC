class CreateReportStatuses < ActiveRecord::Migration
  def change
    create_table :report_statuses do |t|
      t.integer :status, null: false, default: 0
      t.string :filename
      t.string :path
      t.string :error_message

      t.timestamps
    end
  end
end
