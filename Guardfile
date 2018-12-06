# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
# directories %w(app lib config test spec features) \
#  .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard :minitest, first_match: true, spring: true, all_on_start: false, cli: "--color --fast_fail" do

  functional_crm_test = [Dir[File.join('test/jobs/crm/functional*_test.rb')], *Dir[File.join("test/jobs/crm/sync_job_test.rb")]]
  all_salesforce = [*Dir[File.join("test/jobs/crm/**/*sync_job*_test.rb")], *functional_crm_test, *Dir[File.join("test/jobs/crm/adapters/**/*_test.rb")]]

  watch(%r{^app/jobs/crm/adapters/base.rb$})              { [*Dir[File.join("test/jobs/crm/adapters/**/*_test.rb")], *functional_crm_test] }
  watch(%r{^app/jobs/crm/salesforce_sync_job.rb$})        { [*all_salesforce] }
  watch(%r{^app/models/concerns/salesforce_record_concern.rb$}) { [*all_salesforce] }
  watch(%r{^app/models/concerns/salesforce_commit_hooks_concern.rb$}) { [*functional_crm_test] }

  watch(%r{^app/jobs/crm/adapters/(.+)\.rb$})             { |m| ["test/jobs/crm/adapters/#{m[1]}_test.rb", *functional_crm_test] }
  watch(%r{^app/jobs/(.+)_job\.rb$})                      { |m| ["test/jobs/#{m[1]}_job_test.rb", *functional_crm_test] }

  watch(%r{^app/controllers/application_controller\.rb$}) { %w[test/controllers test/integration] }
  watch(%r{^app/controllers/(.+)_controller\.rb$})        { |m| ["test/controllers/#{m[1]}_controller_test.rb", "test/integration/#{m[1]}_test.rb"]}
  watch(%r{^app/views/(.+)_mailer/.+})                    { |m| "test/mailers/#{m[1]}_mailer_test.rb" }
  watch(%r{^app/(.+)\.rb$})                               { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^lib/(.+)\.rb$})                               { |m| "test/lib/#{m[1]}_test.rb" }
  watch(%r{^test/.+_test\.rb$})
  watch(%r{^test/test_helper\.rb$}) { 'test' }

  # Note the `nil` at the end to avoid passing file to plugin
  # watch(/(.*)/) { |m| Guard::UI.info "Unknown file: #{m[1]}"; nil }
end

guard 'spring', bundler: true do
  watch('Gemfile.lock')
  watch(%r{^config/})
  watch(%r{^spec/(support|factories)/})
  watch(%r{^spec/factory.rb})
end

guard :rake, task: 'factory_bot:lint', all_on_start: false do
  watch(%r{^test/factories/(.+)s.rb$}) { |m| "#{m[1]}" }
end