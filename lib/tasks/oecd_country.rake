namespace :oecd do

  desc "set OECD indicators for designated countries"
  task :country => :environment do

    oecd_countries = [10,9,15,30,36,44,47,52,230,61,45,72,82,90,84,85,91,95,103,
      116,138,147,152,231,160,165,182,180,56,190,34,202,63,209]

    set_oced_countries(oecd_countries)
    puts
    puts 'OECD indicators are now set'
    puts
  end

  def set_oced_countries(country_ids)
    countries = country_ids.each do |country|
      c = Country.find(country)
      c.oecd = true
      c.save!
    end
  end
end
