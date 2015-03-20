desc 'Remove signings and initiatives that where used to store contributions'

task :clean_initiatives_and_signings => :environment do |t|
  Signing.joins(:initiative).where("name LIKE '%Foundation Contributors'").destroy_all
  Initiative.where("name LIKE '%Foundation Contributors'").destroy_all
end

