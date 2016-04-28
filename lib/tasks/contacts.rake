namespace :contacts do

  desc "update password hashes for users with plaintext passwords"
  task :rehash_passwords => :environment do
    UpgradePasswordHash.upgrade_all
    puts "upgrade password jobs enqueued"
  end
end
