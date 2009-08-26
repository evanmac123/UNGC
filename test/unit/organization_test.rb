require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_belong_to :sector
  should_belong_to :organization_type
end
