class CreateActionPlatformPlatforms < ActiveRecord::Migration
  def change
    create_table :action_platform_platforms do |t|
      t.string :name
      t.text :description
      t.integer :status

      t.timestamps null: false
    end
  end
end
