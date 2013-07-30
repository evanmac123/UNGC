# Load the rails application
require File.expand_path('../application', __FILE__)

# Silence deprecation notices caused by Moonshine plugins
::ActiveSupport::Deprecation.silenced = true

# Initialize the rails application
UNGC::Application.initialize!
