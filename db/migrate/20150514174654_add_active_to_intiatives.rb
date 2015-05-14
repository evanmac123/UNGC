class AddActiveToIntiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :active, :boolean, default: true
  end
end
