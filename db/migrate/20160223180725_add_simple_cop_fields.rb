class AddSimpleCopFields < ActiveRecord::Migration
  def change
    add_column :communication_on_progresses, :endorses_ten_principles, :boolean
    add_column :communication_on_progresses, :covers_issue_areas, :boolean
    add_column :communication_on_progresses, :measures_outcomes, :boolean
    add_column :communication_on_progresses, :type, :string, default: 'CommunicationOnProgress', null: false
  end
end
