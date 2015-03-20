class UpdateErrorMessageTypeForReportStatuses < ActiveRecord::Migration
  def change
    change_column :report_statuses, :error_message, :text
  end
end
