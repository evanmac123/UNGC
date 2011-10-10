class ConvertCountryRegionNamesToHashKeys < ActiveRecord::Migration
  def self.up
    Country::REGIONS.values.each do |region|
      Country.update_all( "region = '#{Country::REGIONS.key(region)}'", "region = '#{region}'" )
    end
  end

  def self.down
    Country::REGIONS.keys.each do |region|
      Country.update_all( "region = '#{Country::REGIONS[region]}'", "region = '#{region}'" )
    end
  end
end
