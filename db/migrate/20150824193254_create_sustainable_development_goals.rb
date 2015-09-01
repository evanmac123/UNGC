class CreateSustainableDevelopmentGoals < ActiveRecord::Migration
  def change
    create_table :sustainable_development_goals do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
