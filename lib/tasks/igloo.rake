# require './lib/igloo/igloo_api.rb'

desc "sycn contacts with Igloo every 5 minutes"
task igloo_sync: :environment do |t, args|
  puts "something"
  # contacts = IglooContactsQuery.run

  api_key = "94a395ea-1954-47c7-963b-8285aed7b9e5"
  password = "N+-z=127_568VqX"
  apibaseurl = "https://unglobalcompact.igloocommunities.com"
  apimethod = "users/#{}"

  credentials = {
    appId: api_key,
    appPass: password,
    username: "katzen@unglobalcompact.org",
    password: "password123",
    community: "unglobalcompact.igloocommunities.com"
  }

  ungc_sam_id = 178911
  sam = "6e56582e-eecc-4a31-b6e1-38d4a81f8ecb"

  igloo = Igloo::IglooApi.new(credentials)
  igloo.authenticate
  # igloo.find_user(sam)
  # igloo.update_user(sam, "Sam works for the UNGC")

  abin = Contact.find_by(email: "abraham@unglobalcompact.org")
  ben = Contact.find_by(email: "ben@unspace.ca")
  contacts = [abin, ben]
  igloo.bulk_upload(contacts)
end
