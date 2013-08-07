require "./lib/importers/tools_and_resources"

desc 'Import Tools and Resources from excel. usage: rake import_tools_and_resources[path/to/file.xls]'
task :import_tools_and_resources, [:path] => :environment do |t, args|
  Importers::ToolsAndResourcesImporter.import(args[:path])
end
