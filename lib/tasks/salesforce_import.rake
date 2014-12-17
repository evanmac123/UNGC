require './lib/salesforce/salesforce_importer'

desc "Import Campaign and Contribution data from salesforce"
task :salesforce_import, [:path] => :environment do |t, args|
  path = args[:path]
  raise "usage: rake salesforce_import[<path_to_csv_directory>]" if path.nil?
  SalesforceImporter.import_from(path)
end
