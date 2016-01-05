class AddSubmissionStatusToCommunicationOnProgress < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :submission_status, :integer, default: 0, null: false
    add_index :communication_on_progresses, :submission_status
  end
end
