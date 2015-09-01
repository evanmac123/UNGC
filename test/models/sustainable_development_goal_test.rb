require 'test_helper'

class SustainableDevelopmentGoalTest < ActiveSupport::TestCase
  should 'require a name' do
    assert_raise ActiveRecord::RecordInvalid do
      create_sustainable_development_goal name: nil
    end
  end

  should 'have a name' do
    sdg = create_sustainable_development_goal name: 'foo'
    assert_equal 'foo', sdg.name
  end
end
