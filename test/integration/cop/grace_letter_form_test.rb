require 'test_helper'

module COP
  class GraceLetFormTest < ActionDispatch::IntegrationTest

    setup do
      travel_to Date.new(2016, 7, 6)
    end

    teardown do
      travel_back
    end

    test "handle COP submission lifecycle" do
    end

  end
end
