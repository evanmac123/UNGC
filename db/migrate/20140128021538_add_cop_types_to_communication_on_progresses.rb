class AddCopTypesToCommunicationOnProgresses < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :cop_type, :string
  end
end
