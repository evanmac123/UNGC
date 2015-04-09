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

  should 'cache a count of its immediate child containers' do
    container1 = create_container!
    container2 = create_container!(parent_container_id: container1.id)
    container3 = create_container!(parent_container_id: container2.id)
    container4 = create_container!(parent_container_id: container3.id)

    container1.reload
    container2.reload
    container3.reload
    container4.reload

    assert_equal 1, container1.child_containers_count
    assert_equal 1, container2.child_containers_count
    assert_equal 1, container3.child_containers_count
    assert_equal 0, container4.child_containers_count

    container4.update!(parent_container_id: container1.id)

    container1.reload
    container2.reload
    container3.reload

    assert_equal 2, container1.child_containers_count
    assert_equal 1, container2.child_containers_count
    assert_equal 0, container3.child_containers_count
    assert_equal 0, container4.child_containers_count

    container2.destroy!

    container1.reload
    container3.reload
    container4.reload

    assert_equal container1.id, container3.parent_container_id
    assert_equal 2, container1.child_containers_count
    assert_equal 0, container3.child_containers_count
    assert_equal 0, container4.child_containers_count
  end
end
