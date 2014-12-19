require './lib/salesforce/installer'

desc "Installs classes, triggers and custom objects in Salesforce"
task :salesforce_install, [:env] => [:salesforce_install_classes, :salesforce_install_triggers] do |t, args|
end

desc "Installs classes in Salesforce"
task :salesforce_install_classes, [:env] => :environment do |t, args|
  installer(args[:env]).create_classes
end

desc "Installs triggers in Salesforce"
task :salesforce_install_triggers, [:env] => :environment do |t, args|
  installer(args[:env]).create_triggers
end

desc "Shows the pending sync queue"
task :salesforce_show_pending, [:env] => :environment do |t, args|
  queue = installer(args[:env]).show_sync_queue
  if queue.empty?
    puts "The pending queue is empty."
  else
    puts queue.inspect
  end
end

desc "Clears the pending sync queue"
task :salesforce_clear_pending, [:env] => :environment do |t, args|
  installer(args[:env]).clear_sync_queue
end

private

def settings
  @settings ||= YAML.load_file(Rails.root.join('config/defaults.yml'))
end

def installer(env)
  env ||= Rails.env
  @installers ||= {}
  @installers[env] ||= create_installer(env)
  @installers[env]
end

def create_installer(env)
  config = settings[env]['salesforce']
  raise "no salesforce config for env: #{env}" if config.nil?
  SalesforceInstaller.new(config)
end
