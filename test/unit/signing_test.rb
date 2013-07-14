require 'test_helper'

class SigningTest < ActiveSupport::TestCase
  should validate_presence_of :organization_id

  should belong_to :initiative
  should belong_to :signatory
  should belong_to :organization
end
