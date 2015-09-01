class DropCaseStoriesCountries < ActiveRecord::Migration
  def change
    drop_table :case_stories_countries
  end
end
