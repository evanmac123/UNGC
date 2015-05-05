require 'yaml'
require 'sass/script/functions'

module Sass::Script::Functions
  def color(color_name)
    colors = YAML.load_file(Rails.root.join('config', 'colors.yml'))
    Sass::Script::Value::Color.from_hex(colors[color_name.to_s.gsub('"', '')])
  end
end
