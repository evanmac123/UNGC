class PopulateContentVersions < ActiveRecord::Migration
  def self.up
    Content.find_each do |c|
      c.versions.create c.attributes.merge({
        :number   => 1,
        :approved => true
      })
    end
  end

  def self.down
  end
end
