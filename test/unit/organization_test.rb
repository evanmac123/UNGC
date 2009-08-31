require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_many :contacts
  should_belong_to :sector
  should_belong_to :organization_type
  should_belong_to :country
end
