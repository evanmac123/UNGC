class CreateCopAnswers < ActiveRecord::Migration
  def self.up
    create_table :cop_answers do |t|
      t.integer :cop_id
      t.integer :cop_attribute_id
      t.boolean :value

      t.timestamps
    end
  end

  def self.down
    drop_table :cop_answers
  end
end
