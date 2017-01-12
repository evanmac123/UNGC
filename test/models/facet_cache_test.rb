require 'test_helper'

class FacetCacheTest < ActiveSupport::TestCase

  setup    { cache.clear }
  teardown { cache.clear }

  context 'puting' do

    should 'store and retrieve a value' do
      cache.put('hello', sample)
      assert_equal sample, cache.fetch('hello')
    end

  end

  context 'fetch' do

    should 'fetch a known value' do
      cache.put('hello', sample)
      assert_equal sample, cache.fetch('hello')
    end

    should 'return nil for an unknown key' do
      assert_nil cache.fetch('unknown')
    end

    should 'return return a default value when provided' do
      cache.fetch('unknown') { sample }
      assert_equal sample, cache.fetch('unknown')
    end

  end

  context 'delete' do

    setup {
      cache.put('one', sample)
      cache.put('two', sample)
      cache.delete('one')
    }

    should 'delete the specified key' do
      assert_nil cache.fetch('one')
    end

    should 'NOT delete any other key' do
      assert_not_nil cache.fetch('two')
    end

  end

  context 'count' do

    should 'count the key/value pairs' do
      assert_difference -> { cache.count }, +2 do
        cache.put('one', sample)
        cache.put('two', sample)
      end
    end

  end

  context 'clear' do

    setup {
      cache.put('one', sample)
      cache.put('two', sample)
    }

    should 'clear the whole cache' do
      assert_difference -> { cache.count }, -2 do
        cache.clear
      end

      assert_nil cache.fetch('one')
      assert_nil cache.fetch('two')
    end

  end

  private

  def cache
    @cache ||= FacetCache.new('facet-cache-test')
  end

  def sample
    {
      one: {
        1 => 3,
        2 => 4
      }
    }
  end

end
