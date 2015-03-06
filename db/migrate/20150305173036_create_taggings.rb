class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.references :author, index: true
      t.references :principle, index: true
      t.string :principle_type, index: true
      t.references :country, index: true
      t.references :initiative, index: true
      t.references :language, index: true
      t.references :sector, index: true
      t.references :communication_on_progress, index: true
      t.references :event, index: true
      t.references :headline, index: true
      t.references :organization, index: true
      t.references :resource, index: true
      t.references :redesign_container, index: true

      t.timestamps null: false
    end
    add_foreign_key :taggings, :redesign_containers#, column: :container
    add_foreign_key :taggings, :authors
    add_foreign_key :taggings, :principles
    add_foreign_key :taggings, :countries
    add_foreign_key :taggings, :initiatives
    add_foreign_key :taggings, :languages
    add_foreign_key :taggings, :sectors
    add_foreign_key :taggings, :communication_on_progresses
    add_foreign_key :taggings, :events
    add_foreign_key :taggings, :headlines
    add_foreign_key :taggings, :organizations
    add_foreign_key :taggings, :resources
  end
end
