require 'rake'
require 'airbrake/rake_handler'

Airbrake.configure do |config|
  config.api_key = 'e343d87f3613e217edf16597f119ecc7'
  config.rescue_rake_exceptions = true
end
