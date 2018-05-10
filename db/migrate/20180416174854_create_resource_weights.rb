class CreateResourceWeights < ActiveRecord::Migration
  def change
    enable_extension 'citext'

    create_table :resource_weights do |t|
      t.references :resource, index: true, foreign_key: true
      t.text :full_text, null: false
      t.text :full_text_raw, null: false
      t.jsonb :weights, null: false, default: "{}"

      # TODO: figure out if these are needed or not.
      t.text :resource_title, null: false
      t.text :resource_url, null: false
      t.text :resource_type, null: false

      t.timestamps null: false
    end

    add_index :resource_weights, :weights, using: :gin
  end
end
