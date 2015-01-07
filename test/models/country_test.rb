require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  should validate_presence_of :name
  should validate_presence_of :code
  should validate_presence_of :region
  should have_and_belong_to_many :case_stories
  should have_and_belong_to_many :communication_on_progresses
  should belong_to :local_network
end
