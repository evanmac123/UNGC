class CreateCaseStoriesCountries < ActiveRecord::Migration
  def self.up
    create_table :case_stories_countries, :id => false do |t|
      t.integer :case_story_id
      t.integer :country_id
    end
  end

  def self.down
    drop_table :case_stories_countries
  end
end
