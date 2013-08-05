class CreateAuthors < ActiveRecord::Migration
  def up
    create_table :authors do |t|
      t.string :full_name
      t.string :acronym
      t.timestamps
    end
  end

  def down
    drop_table :authors
  end
end
