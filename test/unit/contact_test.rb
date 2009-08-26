require 'test_helper'

class ContactTest < ActiveSupport::TestCase
  should_validate_presence_of :first_name, :last_name
end
