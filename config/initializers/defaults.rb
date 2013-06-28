target = Rails.root.join('config/defaults.yml')
env = Rails.env
DEFAULTS = YAML.load_file(target)[env].symbolize_keys
