require 'test_helper'

class RegionTest < ActiveSupport::TestCase

  should "have :name, :title, :param" do
    r = Region.new('test', 'Test', 'test-me')
    assert_equal r.name, 'test'
    assert_equal r.title, 'Test'
    assert_equal r.param, 'test-me'
  end

  should 'retrieve an existing region by name' do
    assert Region.find_by(name: 'africa')
  end

  should 'retrieve an existing region by param' do
    assert Region.find_by(param: 'africa')
  end

  should 'not retrieve a non existing region' do
    refute Region.find_by(name: 'fake')
  end

end
