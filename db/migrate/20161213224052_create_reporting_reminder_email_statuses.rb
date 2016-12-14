class CreateReportingReminderEmailStatuses < ActiveRecord::Migration
  def change
    create_table :reporting_reminder_email_statuses do |t|
      t.integer :organization_id, null: false
      t.boolean :success, null: false
      t.text    :message
      t.string  :reporting_type
      t.string  :email

      t.timestamps null: false
    end
  end
end
