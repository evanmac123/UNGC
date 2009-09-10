class CreateContentTemplates < ActiveRecord::Migration
  def self.up
    create_table :content_templates do |t|
      t.string :filename
      t.string :label
      t.boolean :default

      t.timestamps
    end
  end

  def self.down
    drop_table :content_templates
  end
end
