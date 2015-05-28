require 'test_helper'

Searchable = Redesign::Searchable::SearchableContainer

class Redesign::Searchable::SearchableContainerTest < ActiveSupport::TestCase

  should "not include a container with only a draft_payload" do
    create_container
    assert_equal 0, Searchable.all.count
  end

  should "include published containers" do
    create_published_contaner
    assert_equal 1, Searchable.all.count
  end

  should "have an empty title if there is no meta title" do
    searchable = Searchable.new(published_container)
    assert_equal "", searchable.title
  end

  should "index the title from the payload" do
    data = {meta_tags: {title: 'foo'}}
    searchable = Searchable.new(published_container(data: data))
    assert_equal 'foo',  searchable.title
  end

  should "index the url from the container's path" do
    searchable = Searchable.new(published_container(params: {path: '/one/two/three'}))
    assert_equal '/one/two/three', searchable.url
  end

  should "squash the container's payload as the content" do
    data = {
      meta_tags: {
        title: 'meta_title'
      },
      one: {
        two: {
          three: "<html>baseball</html>"
        }
      },
      five: [
        "apple",
        "orange",
        "banana",
        "<script>alert('hax');</script>"
      ],
      hmm: 12345
    }
    searchable = Searchable.new(published_container(data: data))
    assert_equal 'meta_title baseball apple orange banana  12345', searchable.content
  end

  should "delete the searchable when the Container is deleted" do
    skip
    container = create_published_contaner
    Redesign::Searchable.index_all
    assert_difference 'Redesign::Searchable.count', -1 do
      container.destroy
    end
  end

  should "should replace the searchable when the container changes path" do
    skip
  end

  private

  def unpublished_container
    @unpublished_container ||= create_container
  end

  def published_container(*args)
    @published_container ||= create_published_contaner(*args)
  end

  def create_published_contaner(params: {}, data: {})
    create_country # for the contact
    container = create_container(params)
    container.draft_payload = create_payload(container_id: container.id, json_data: data.to_json)
    assert ContainerPublisher.new(container, create_contact).publish
    container
  end

end
