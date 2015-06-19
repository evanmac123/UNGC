class Region

  attr_reader :name, :title, :param

  def initialize(name, title, param)
    @name = name
    @title = title
    @param = param
  end

  def self.find_by(name: nil, param: nil)
    regions.find do |r|
      r.name == name || r.param == param
    end
  end

  def self.regions
    @regions ||= [
      Region.new('africa', 'Africa', 'africa'),
      Region.new('asia', 'Asia', 'asia'),
      Region.new('europe', 'Europe', 'europe'),
      Region.new('latin_america', 'Latin America &amp; Caribbean', 'latin-america'),
      Region.new('mena', 'MENA', 'mena'),
      Region.new('northern_america', 'North America', 'north-america'),
      Region.new('oceania', 'Oceania', 'oceania')
    ]
  end
end
