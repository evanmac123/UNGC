require 'test_helper'

class CountryTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :code
  should_have_and_belong_to_many :case_stories
  should_have_and_belong_to_many :communication_on_progresses
  should_belong_to :local_network
end
