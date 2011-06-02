class AddDifferentiationToCommunicationOnProgress < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :differentiation, :string
  end

  def self.down
    remove_column :communication_on_progresses, :differentiation
  end
end
