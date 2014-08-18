class AddIndexOnSearchablesIdAndDelta < ActiveRecord::Migration
  def up
    add_index :searchables, [:id, :delta], :name => 'index_searchables_on_id_and_delta'
  end

  def down
    remove_index :searchables, :name => 'index_searchables_on_id_and_delta'
  end
end
