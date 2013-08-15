require "./lib/importers/tools_and_resources_importer"
require "./lib/importers/issues_and_topics_importer"


desc 'Import Tools and Resources from excel. usage: rake import_tools_and_resources[path/to/file.xls]'
task :import_tools_and_resources, [:path] => :environment do |t, args|
  errors = Importers::ToolsAndResourcesImporter.import(args[:path])
  puts errors.inspect
end

desc 'Import Issues and Topics from excel. usage: rake import_issues_and_topics[path/to/file.xls]'
task :import_issues_and_topics, [:path] => :environment do |t, args|
  Importers::IssuesAndTopicsImporter::Base.new(args[:path]).run
end
