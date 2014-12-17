class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :campaign_id, null: false
      t.string :name, null: false
      t.date :start_date
      t.date :end_date
      t.integer :initiative_id
      t.boolean :is_deleted, null: false, default: false
      t.timestamps
    end

    add_index :campaigns, :campaign_id, unique: true
    add_index :campaigns, :initiative_id
  end
end
