# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Silence deprecation notices caused by Moonshine plugins
::ActiveSupport::Deprecation.silenced = true

# Initialize the Rails application.
Rails.application.initialize!
