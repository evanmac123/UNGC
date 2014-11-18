  # rails runner 'InsertRegionalCenter.new.run' -e production

class InsertRegionalCenter
  def run
    regional_center = LocalNetwork.create(name: "Regional Center",
                                          state: "regional_center",
                                          funding_model: "independent")
                                          
    # assign regional center to countries in latin america
    latin_american_countries = Country.where_region(:latin_america)
    latin_american_countries.each do |country|
      country.regional_center = regional_center
      country.save      
    end
                                          
  end
end
