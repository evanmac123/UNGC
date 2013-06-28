require 'test_helper'

class LogoFileTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :thumbnail
end
