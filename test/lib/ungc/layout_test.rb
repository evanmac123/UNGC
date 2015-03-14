require 'test_helper'

class UNGC::LayoutTest < ActiveSupport::TestCase
  def extend_class(&block)
    Class.new(UNGC::Layout, &block)
  end

  context 'Class' do
    should 'allow multiple containers by default' do
      layout = extend_class
      assert layout.has_many_containers?
    end

    should 'enforce a single container to be specified' do
      layout = extend_class { has_one_container! }
      assert !layout.has_many_containers?
    end

    should 'have a label' do
      layout = extend_class { label 'Test' }
      assert_equal layout.label, 'Test'
    end

    should 'have a layout identifier used to filter on Container#layout' do
      layout = extend_class { layout 'test' }
      assert_equal layout.layout, :test
    end

    should 'allow fields to be added' do
      layout = extend_class { field :base_key, type: :string }
      assert layout.root_scope.slots[:base_key].is_a?(UNGC::Field)
    end

    should 'allow scopes to be added' do
      layout = extend_class do
        scope :ns do
          field :test, type: :string
        end
      end

      assert layout.root_scope.slots[:ns].is_a?(UNGC::Scope)
    end
  end

  class TestLayout < UNGC::Layout
    layout :test

    scope :namespace do
      field :test, type: :string
    end

    scope :array, array: true, min: 3 do
      field :value, type: :string
    end
  end

  should 'materialze from a payload' do
    layout = TestLayout.new({
      'namespace' => {
        'test' => 'hello'
      },

      'array' => [
        { 'value' => 'yo' },
        { 'value' => 'sup' },
        { 'value' => 'neat' }
      ]
    })

    assert_equal layout.as_json[:namespace][:test], 'hello'
    assert_equal layout.as_json[:array][2][:value], 'neat'
  end
end
