require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_many :contacts
  should_have_many :logo_requests
  should_have_many :case_stories
  should_have_many :communication_on_progresses
  should_belong_to :sector
  should_belong_to :organization_type
  should_belong_to :listing_status
  should_belong_to :exchange
  should_belong_to :country
end
