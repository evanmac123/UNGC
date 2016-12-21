require Rails.root.join('lib', 'find_and_destroy_orphans').to_s

namespace :cop do
  desc "Find and destroy orphaned CopFiles"
  task orphan_destroy: :environment do
    puts "Finding Orphan Files"
    orphan_cops_files = FindAndDestroyOrphans.new
    puts "Aiming Lasers"
    puts "Destroying Orphan Files"
    orphan_cops_files.destroy_orphans
    puts "Long live the Empire"
  end
end
