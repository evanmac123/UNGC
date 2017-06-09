desc "sync contacts with Igloo every 5 minutes"
task igloo_sync: :environment do |t, args|

  credentials = {
    appId: "94a395ea-1954-47c7-963b-8285aed7b9e5",
    appPass: "N+-z=127_568VqX",
    username: "katzen@unglobalcompact.org",
    password: "password123",
    community: "unglobalcompact.igloocommunities.com"
  }

  igloo = Igloo::IglooApi.new(credentials)
  igloo.authenticate

  contacts = IglooContactsQuery.new.run
  puts "Syncing #{contacts.count} contacts"
  igloo.bulk_upload(contacts)
  puts "Done."
end
