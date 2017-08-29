require 'test_helper'

class DataVisualization::SectorsController::SectorDataTest < ActionController::TestCase
  test "should calculate" do
    @country = create(:country)
    @sector = create(:sector, name: "Mining")

    # Given a mining company that joined in 2015
    @organization1 = create(:organization, participant: true, joined_on: "Wed, 15 Mar 2015", country: @country, sector: @sector)

    # And a mining company that joined in 2014, but was delisted in 2015
    @organization2 = create(:organization, participant: true, joined_on: "Wed, 14 Mar 2014", country: @country, sector: @sector)
    @organization2.delisted_on = Date.new(2015,03,14)

    # And a mining company that joined in in 2013, was delisted in 2014, and rejoined in 2015
    @organization3 = create(:organization, participant: true, joined_on: "Wed, 14 Mar 2013", country: @country, sector: @sector)
    @organization3.delisted_on = Date.new(2014,03,14)
    @organization3.rejoined_on = Date.new(2015,03,14)

    # When we run the sector growth query
    sector_data = DataVisualization::SectorsController::SectorData.new(@country.id)
    growth =  sector_data.sector_growth_calculation


    # Then we see that the mining sector has growth of 1 in 2015

    assert_includes growth, { sector_name: "Mining", year: 2013, count: 1 }
    assert_includes growth, { sector_name: "Mining", year: 2014, count: 0 }
    assert_includes growth, { sector_name: "Mining", year: 2015, count: 2 }
  end
end
