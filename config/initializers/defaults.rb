target = RAILS_ROOT + '/config/defaults.yml'
env = ENV['RAILS_ENV'] || 'development'
DEFAULTS = YAML.load_file(target)[env].symbolize_keys
