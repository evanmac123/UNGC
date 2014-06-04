class AddPublishedOnToCommunicationOnProgress < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :published_on, :date
  end
end
