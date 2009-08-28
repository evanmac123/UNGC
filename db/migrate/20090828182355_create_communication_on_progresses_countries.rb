class CreateCommunicationOnProgressesCountries < ActiveRecord::Migration
  def self.up
    create_table :communication_on_progresses_countries, :id => false do |t|
      t.integer :communication_on_progress_id
      t.integer :country_id
    end
  end

  def self.down
    drop_table :communication_on_progresses_countries
  end
end
