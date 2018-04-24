desc "update the participant_manager_id on the countries table"
task participant_manager_update: :environment do |t, args|

  countries = Country.all

  countries.each do |country|
    if country.name == 'Morocco'
      country.participant_manager_id = 24768
    elsif country.region == 'asia'
      country.participant_manager_id = 326110
    elsif country.region =='oceania'
      country.participant_manager_id = 326110
    elsif country.region == 'mena'
      country.participant_manager_id = 32100
    elsif country.region == 'africa'
      country.participant_manager_id = 24768
    else
      country.participant_manager_id
    end
    country.save!
  end

  puts "******* Participant Manager IDs Are Now Updated *******"

end
