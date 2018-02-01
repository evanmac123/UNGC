class AddAcademyToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_academy, :boolean
  end
end
