require 'test_helper'

class ResourceTest < ActiveSupport::TestCase
  should have_and_belong_to_many :principles
  should have_and_belong_to_many :authors
  should have_many :resource_links
end
