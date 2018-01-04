class DataVisualization::SectorDataQueries
  attr_reader :data
  def initialize(country_id)
    @data = Organization
    .joins(:sector)
    .where(participant: true)
    .where(organizations: {country_id: country_id})
    .where("sectors.name != ?", 'Not Applicable')

    @country_name = Country.find(country_id).name
  end

  def business_sectors_in_country
    sectors_with_companies = sector_count.reject { |sector, count| count == 0 }
    sectors_with_companies.map do |sector_name, count|
      { sector_name: sector_name, count: count, country_name: @country_name }
    end
  end

  def business_sector_growth_mapping
    sectors_that_change = sector_change_by_year.reduce({}) { |acc, (key, value)| acc[key] = value if value.keys.length > 1; acc }
    sectors_that_change.flat_map do |sector_name, year|
      year.map do |year, count|
        { sector_name: sector_name, year: year, count: count, country_name: @country_name }
      end
    end
  end

  def joined_on_by_year
    joined_on = data.group(:sector_id, 'EXTRACT(YEAR FROM joined_on)').pluck('sectors.name, EXTRACT(YEAR FROM organizations.joined_on), count(organizations.id) as organization_count')
    joined_on.map do |sector_name, year, count|
      { sector_name: sector_name, year: year, count: count }
    end
  end

  def rejoined_on_by_year
    rejoined_on = data.group(:sector_id, 'EXTRACT(YEAR FROM rejoined_on)').where.not(rejoined_on: nil).pluck('sectors.name, EXTRACT(YEAR FROM organizations.rejoined_on), count(organizations.id) as organization_count')
    rejoined_on.map do |sector_name, year, count|
      { sector_name: sector_name, year: year, count: count }
    end
  end

  def expulsion_by_year
    delisted_on = data.group(:sector_id, 'EXTRACT(YEAR FROM delisted_on)').where.not(delisted_on: nil).pluck('sectors.name, EXTRACT(YEAR FROM organizations.delisted_on), count(organizations.id) as organization_count')
    delisted_on.map do |sector_name, year, count|
      { sector_name: sector_name, year: year, count: count, country_name: @country_name }
    end
  end

  def sector_growth_calculation
    output = {}
    joined_on_by_year.each do |row|
      year = row[:year]
      sector = row[:sector_name]
      count = row[:count]

      if output[sector] == nil
        output[sector] = Hash.new
      end
      output[sector][year] = count
    end

    expulsion_by_year.each do |row|
      year = row[:year]
      sector = row[:sector_name]
      count = row[:count]

      join_count = output[sector][year] || 0

      output[sector][year] = join_count - count
    end

    rejoined_on_by_year.each do |row|
      year = row[:year]
      sector = row[:sector_name]
      count = row[:count]

      delist_count = output[sector][year] || 0

      output[sector][year] = delist_count + count
    end
    output
  end

  def sector_count
    sector_growth_calculation.reduce({}) { |total, (sector, count_for_year)|  total[sector] = count_for_year.map { |k, v| v }.reduce(:+); total }
  end

  def sector_change_by_year
    sector_growth_calculation.reduce({})  do
      |acc, (sector, years)|
      year_arr = years.sort
      acc[sector] ||= []
      year_arr.each_with_index do |(year, count), index|
        if index == 0
          acc[sector] << [year, count > 0 ? count : 0]
        else
          acc[sector] << [year, acc[sector][index - 1][1] + count]
        end
      end
      acc[sector] = acc[sector].to_h

      acc
    end
  end

end
