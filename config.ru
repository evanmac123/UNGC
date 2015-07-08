# This file is used by Rack-based servers to start the application.
require 'coverband'

Coverband.configure
Rails.application.config.middleware.use Coverband::Middleware

require ::File.expand_path('../config/environment', __FILE__)
run Rails.application
