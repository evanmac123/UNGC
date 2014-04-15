class RemoveEmailAndJobTitleFromCommunicationOnProgresses < ActiveRecord::Migration
  def up
    remove_column :communication_on_progresses, :email
    remove_column :communication_on_progresses, :job_title
  end

  def down
    add_column :communication_on_progresses, :job_title, :string
    add_column :communication_on_progresses, :email, :string
  end
end
