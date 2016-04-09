class CreateCopLogEntries < ActiveRecord::Migration
  def change
    create_table :cop_log_entries do |t|
      t.string :event
      t.string :cop_type
      t.string :status
      t.text :error_message
      t.references :contact, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
      t.text :params

      t.timestamps null: false
    end
  end
end
