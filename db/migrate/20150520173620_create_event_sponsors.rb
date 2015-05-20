class CreateEventSponsors < ActiveRecord::Migration
  def change
    create_table :event_sponsors do |t|
      t.references :event, index: true, foreign_key: true
      t.references :sponsor, index: true, foreign_key: true
    end
  end
end
