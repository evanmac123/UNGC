class CreateHeadlines < ActiveRecord::Migration
  def self.up
    create_table :headlines do |t|
      t.string   :title
      t.text     :description
      t.string   :location
      t.date     :published_on
      t.integer  :created_by_id
      t.integer  :updated_by_id
      t.string   :approval
      t.datetime :approved_at
      t.integer  :approved_by_id
      t.integer  :country_id

      t.timestamps
    end
  end

  def self.down
    drop_table :headlines
  end
end
