class RenameNordicNetwork < ActiveRecord::Migration
  def up
    LocalNetwork.update_all({name: 'Nordic Countries'}, ["name = ?", 'Nordic Network'])
  end

  def down
    LocalNetwork.update_all({name: 'Nordic Network'}, ["name = ?", 'Nordic Countries'])
  end
end
