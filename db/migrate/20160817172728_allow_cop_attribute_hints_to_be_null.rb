class AllowCopAttributeHintsToBeNull < ActiveRecord::Migration
  def change
    change_column :cop_attributes, :hint, :text, null: true
  end
end
