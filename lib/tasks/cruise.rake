desc 'Continuous build target'
task :cruise do
  cp 'config/database.yml.rail', 'config/database.yml'
  Rake::Task["db:migrate"].invoke
  Rake::Task["test"].invoke
end