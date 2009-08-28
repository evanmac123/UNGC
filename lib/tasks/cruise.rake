desc 'Continuous build target'
task :cruise do
  cp 'config/database.yml.rails', 'config/database.yml'
  Rake::Task["db:migrate"].invoke
  Rake::Task["test"].invoke
end