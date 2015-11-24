class AddTypeToCommunicationOnProgress < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :type, :string
  end
end
