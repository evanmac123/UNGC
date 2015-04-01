require 'test_helper'

class Redesign::ContainerTest < ActiveSupport::TestCase
  def create_container!(attrs = {})
    Redesign::Container.create!({
      layout: :article,
      slug: rand.to_s
    }.merge(attrs))
  end

  should 'normalize slugs' do
    assert_equal '/cool', Redesign::Container.normalize_slug('cool')
    assert_equal '/cool', Redesign::Container.normalize_slug('Cool')
    assert_equal '/cool', Redesign::Container.normalize_slug('/Cool')
    assert_equal '/cool', Redesign::Container.normalize_slug('/Cool/')
    assert_equal '/cool', Redesign::Container.normalize_slug('COOL/')
  end

  should 'normalize #path on set' do
    container = create_container!(path: 'wOw/What/a/Path/')
    assert_equal '/wow/what/a/path', container.path
  end

  should 'normalize #slug on set' do
    container = create_container!(slug: 'coolPathBro')
    assert_equal '/coolpathbro', container.slug
  end
end
