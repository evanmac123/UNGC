require 'test_helper'

class Searchable::SearchableContainerTest < ActiveSupport::TestCase
  include SearchableModelTests
  include SearchableTagTests

  should "not include a container with only a draft_payload" do
    create(:container)
    Searchable.index_all
    assert_equal 0, Searchable.all.count
  end

  should "include published containers" do
    create_published_contaner
    Searchable.index_all
    assert_equal 1, Searchable.all.count
  end

  should "have an empty title if there is no meta title" do
    container = published_container(data: {})
    searchable = Searchable::SearchableContainer.new(container)
    assert_equal '', searchable.title
  end

  should "index the title from the payload" do
    searchable = Searchable::SearchableContainer.new(published_container)
    assert_equal 'some title',  searchable.title
  end

  should "index the url from the container's path" do
    searchable = Searchable::SearchableContainer.new(published_container)
    assert_equal '/one/two/three', searchable.url
  end

  should "index meta_tags as meta" do
    data = {
      meta_tags: {
        title: 'meta_title',
        description: 'meta_description',
        keywords: 'one two',
        ignore: 'ignore'
      },
      one: {
        two: {
          title: "<html>baseball</html>"
        }
      },
      five: [
        "apple",
        "orange",
        "banana",
        "<script>alert('hax');</script>",
        {blurb: "nested-hash-value"},
      ],
      title1: 12345,
      key_with_no_value: nil,
    }
    searchable = Searchable::SearchableContainer.new(published_container(data: data))
    assert_equal 'meta_title meta_description one two', searchable.meta
  end

  should "squash the container's payload as the content" do
    data = {
      meta_tags: {
        title: 'meta_title',
        description: 'meta_description'
      },
      one: {
        two: {
          title: "<html>baseball</html>"
        }
      },
      five: [
        "apple",
        "orange",
        "banana",
        "<script>alert('hax');</script>",
        {blurb: "nested-hash-value"},
      ],
      title1: 12345,
      key_with_no_value: nil,
    }
    searchable = Searchable::SearchableContainer.new(published_container(data: data))
    assert_equal 'baseball nested-hash-value 12345', searchable.content
  end

  should "delete the searchable when the Container is deleted" do
    container = create_published_contaner
    Searchable.index_all
    assert_difference 'Searchable.count', -1 do
      container.destroy
    end
  end

  should "should replace the searchable when the container changes path" do
    # create and index a container
    container = create_published_contaner
    Searchable.index_all

    # update the path and re-index
    container.update_attribute(:path, '/new/path')
    Searchable.index_all

    # there should be a searchable with the new path
    assert_not_nil Searchable.find_by(url: '/new/path')

    # there should no longer be a searchable with the old path
    assert_nil Searchable.find_by(url: '/one/two/three')
  end

  should "become searchable when published" do
    container = create(:container)
    Searchable.index_all

    attach_payload(container)
    publisher = ContainerPublisher.new(container, create(:contact))
    assert publisher.publish
    container.save!

    assert_difference 'Searchable.count', +1 do
      Searchable.index_all
    end
  end

  should "no longer be searchable when unpublished" do
    container = create_published_contaner
    Searchable.index_all

    publisher = ContainerPublisher.new(container, create(:contact))

    assert_difference ' Searchable.count', -1 do
      assert publisher.unpublish
    end
  end

  private

  def unpublished_container
    @unpublished_container ||= create(:container)
  end

  def published_container(*args)
    @published_container ||= create_published_contaner(*args)
  end

  alias_method :subject, :published_container

  def create_published_contaner(params: nil, data: nil)
    params ||= {
      path: '/one/two/three'
    }

    data ||= {
      meta_tags: {
        title: 'some title'
      }
    }

    container = create(:container, params)
    container.draft_payload = create(:payload, container_id: container.id, json_data: data.to_json)
    assert ContainerPublisher.new(container, create(:contact)).publish
    container
  end

  def attach_payload(container, data = nil)
    data ||= { meta_tags: { title: 'some title' }}
    container.draft_payload = create(:payload,
      container_id: container.id,
      json_data: data.to_json
    )
  end

end
