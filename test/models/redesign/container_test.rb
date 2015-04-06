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

  should 'maintain its depth in the tree' do
    parent = create_container!
    child  = create_container!(parent_container_id: parent.id)

    assert_equal 0, parent.depth
    assert_equal 1, child.depth
  end

  should 'maintain its path in the tree' do
    parent = create_container!
    child  = create_container!(parent_container_id: parent.id)

    assert_equal "#{parent.id}", parent.tree_path
    assert_equal "#{parent.id}.#{child.id}", child.tree_path
  end

  should 're-cache its childrens tree depth and path' do
    container0 = create_container!
    container1 = create_container!(parent_container_id: container0.id)
    container2 = create_container!(parent_container_id: container1.id)

    assert_equal 2, container2.depth
    assert_equal "#{container0.id}.#{container1.id}.#{container2.id}", container2.tree_path

    container1.update(parent_container_id: nil)

    container2.reload

    assert_equal "#{container1.id}.#{container2.id}", container2.tree_path
    assert_equal 1, container2.depth
  end
end
