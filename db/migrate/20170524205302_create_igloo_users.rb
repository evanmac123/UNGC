class CreateIglooUsers < ActiveRecord::Migration
  def change
    create_table :igloo_users do |t|
      t.references :contact, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
