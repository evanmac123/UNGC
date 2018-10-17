desc "update the participant_manager_id on the organizations table"
task org_participant_manager_update: :environment do |t, args|

  africa_orgs = Organization.joins(:country).where(countries: { region: :africa} ).where(organizations: { active: true } )
  asia_orgs = Organization.joins(:country).where(countries: { region: :asia} ).where(organizations: { active: true } )
  mena_orgs = Organization.joins(:country).where(countries: { region: :mena} ).where(organizations: { active: true } )
  oceania_orgs = Organization.joins(:country).where(countries: { region: :oceania} ).where(organizations: { active: true } )

  AFRICA = 24768
  ASIA = 330565
  OCEANIA = 330565
  MENA = 32100


  puts "******* Updating African Organizations ******"

  africa_orgs.each do |org|
    org.participant_manager_id = AFRICA
    org.save!
  end

  puts "******* African Organizations Updated ******"

  puts "******* Updating Asian Organizations ******"

  asia_orgs.each do |org|
    org.participant_manager_id = ASIA
    org.save!
  end

  puts "******* Asian Organizations Updated ******"

  puts "******* Updating MENA Organizations ******"

  mena_orgs.each do |org|
    if org.country_id == 119
      org.participant_manager_id = 24768
    else
      org.participant_manager_id = MENA
    end
    org.save!
  end

  puts "******* MENA Organizations Updated ******"

  puts "******* Updating Oceania Organizations ******"

  oceania_orgs.each do |org|
    org.participant_manager_id = OCEANIA
    org.save!
  end

  puts "******* Oceania Organizations Updated ******"

  puts "******* Participant Manager IDs Are Now Updated *******"

end
