desc  "sycn contacts with Igloo every 5 minutes"
task :igloo_sync => :environment do |t, args|
  puts "something"
  contacts = IglooContactsQuery.run
  puts contacts.count
  contacts.each do |contact|
      puts contact.first_name
      puts contact.last_name
      puts contact.job_title
      puts contact.organization.name
    end


end
