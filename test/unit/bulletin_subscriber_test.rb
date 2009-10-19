require 'test_helper'

class BulletinSubscriberTest < ActiveSupport::TestCase
  should_validate_presence_of :email
end
