require 'test_helper'

class SigningTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id
  
  should_belong_to :initiative
  should_belong_to :signatory
  should_belong_to :organization
end
