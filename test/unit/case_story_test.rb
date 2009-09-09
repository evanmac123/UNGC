require 'test_helper'

class CaseStoryTest < ActiveSupport::TestCase
  should_validate_presence_of :organization_id, :title
  should_belong_to :organization
  should_have_and_belong_to_many :countries
  should_have_and_belong_to_many :principles
end
