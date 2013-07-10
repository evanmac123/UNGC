require 'test_helper'

class CaseStoryTest < ActiveSupport::TestCase
  should validate_presence_of :organization_id
  should validate_presence_of :title
  should belong_to :organization
  should have_many :comments
  should have_and_belong_to_many :countries
  should have_and_belong_to_many :principles
end
