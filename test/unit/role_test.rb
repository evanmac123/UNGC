require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should_validate_presence_of :name, :description
  should_belong_to :initiative   
end