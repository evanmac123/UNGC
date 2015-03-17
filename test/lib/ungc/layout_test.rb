require 'test_helper'

class UNGC::LayoutTest < ActiveSupport::TestCase
  def extend_layout(&block)
    Class.new(UNGC::Layout, &block)
  end

  context 'Class' do
    should 'allow multiple containers by default' do
      layout = extend_layout
      assert layout.has_many_containers?
    end

    should 'enforce a single container to be specified' do
      layout = extend_layout { has_one_container! }
      assert !layout.has_many_containers?
    end

    should 'have a label' do
      layout = extend_layout { label 'Test' }
      assert_equal layout.label, 'Test'
    end

    should 'have a layout identifier used to filter on Container#layout' do
      layout = extend_layout { layout 'test' }
      assert_equal layout.layout, :test
    end

    should 'allow fields to be added' do
      layout = extend_layout { field :base_key, type: :string }
      assert layout.root_scope.slots[:base_key].is_a?(UNGC::Field)
    end

    should 'allow scopes to be added' do
      layout = extend_layout do
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
        { :value  => 'sup' },
        { 'value' => 'neat' }
      ]
    })

    assert_equal layout.as_json[:namespace][:test], 'hello'
    assert_equal layout.as_json[:array][1][:value], 'sup'
    assert_equal layout.as_json[:array][2][:value], 'neat'
  end

  should 'compile path information for scopes' do
    layout = extend_layout do
      scope :plants do
        scope :fruits do
          field :apples_count, type: :string
        end
      end
    end

    scope = layout.root_scope

    assert_equal scope.slots[:plants].slots[:fruits].path, 'plants.fruits'
  end

  should 'validate max length of text fields' do
    layout = extend_layout do
      field :test, type: :string, limit: 8
    end

    valid   = layout.new(test: '12345678')
    invalid = layout.new(test: '123456789')
    error   = invalid.errors[0]

    assert valid.valid?
    assert !invalid.valid?

    assert_equal :invalid, error[:code]
    assert_equal 'test', error[:path]
    assert_equal 'can not exceed 8 characters', error[:detail]
  end

  should 'validate objects within arrays' do
    layout = extend_layout do
      scope :tests, array: true, size: 2 do
        field :a, type: :string
      end
    end

    valid    = layout.new(tests: [{ a: 'hi' }, { a: 'yo' }])
    invalid1 = layout.new(tests: [{ a: 'hi' }])
    invalid2 = layout.new(tests: nil)
    invalid3 = layout.new(tests: [])
    invalid4 = layout.new(tests: [{ a: 'hi' }, { a: 'bye' }, { a: 'yo' }])

    assert valid.valid?, 'correct number of items is valid'
    assert !invalid1.valid?, 'too few items is invalid'
    assert !invalid2.valid?, 'no array is invalid'
    assert !invalid3.valid?, 'an empty array is invalid'
    assert !invalid4.valid?, 'too many items is invalid'
  end
end
