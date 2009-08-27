require 'test_helper'

class CommunicationOnProgressTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id, :title
  should_belong_to :organization
end
