require 'test_helper'

class AuthorTest < ActiveSupport::TestCase
  should have_and_belong_to_many :resources
end
