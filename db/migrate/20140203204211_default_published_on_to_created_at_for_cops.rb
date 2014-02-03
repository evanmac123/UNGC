class DefaultPublishedOnToCreatedAtForCops < ActiveRecord::Migration
  def up
    CommunicationOnProgress.transaction do
      connection.update('update communication_on_progresses set published_on = created_at')
    end
  end

  def down
    CommunicationOnProgress.transaction do
      connection.update('update communication_on_progresses set published_on = null')
    end
  end
end
