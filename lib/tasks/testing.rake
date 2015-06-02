namespace :test do
  namespace :models do
    desc "Run the unit tests in test/models/redesign/searchables"
    Rake::TestTask.new(:redesign => "db:test:prepare") do |t|
      t.libs << "test"
      t.pattern = 'test/models/redesign/**/*_test.rb'
      t.verbose = true
    end
  end
end
