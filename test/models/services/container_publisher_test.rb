require 'test_helper'

class ContainerPublisherTest < ActiveSupport::TestCase

  context "tags" do
    setup do
      # create some issues and topics to tag with
      water  = create_issue name: 'water'
      earth  = create_issue name: 'earth'
      wind   = create_issue name: 'wind'
      # topics
      fire   = create_topic name: 'fire'
      slush  = create_topic name: 'slush'
      jello  = create_topic name: 'jello'

      # create a container with a draft payload including tags
      container = create_container
      container.draft_payload = create_payload(
        container_id: container.id,
        json_data: {
          taggings: {
            issues: [water.id, wind.id],
            topics: [fire.id, jello.id]
          }
        }.deep_stringify_keys.to_json
      )

      # start the container with some tags
      Tagging.create! redesign_container: container, issue: water
      Tagging.create! redesign_container: container, issue: earth
      Tagging.create! redesign_container: container, topic: fire
      Tagging.create! redesign_container: container, topic: slush

      publisher = ContainerPublisher.new(container)
      publisher.publish

      tags = Tagging.where(redesign_container: container).includes(:issue).includes(:topic)
      @tag_names = tags.map {|t| t.domain.name}
    end

    should "add tags" do
      assert_includes @tag_names, 'wind'
      assert_includes @tag_names, 'jello'
    end

    should "not remove existing tags" do
      assert_includes @tag_names, 'water'
      assert_includes @tag_names, 'fire'
    end

    should "remove old tags" do
      assert_not_includes @tag_names, 'earth'
      assert_not_includes @tag_names, 'slush'
    end
  end

  context 'content_type' do
    setup do
      # create a container with a draft payload including tags
      @container = create_container
      @container.draft_payload = create_payload(
        container_id: @container.id,
        json_data: {
          meta_tags: {
            content_type: 1
          }
        }.deep_stringify_keys.to_json
      )

    end

    should "apply the content_type" do
      assert_equal @container.content_type, 'default'
      publisher = ContainerPublisher.new(@container)
      publisher.publish
      assert_equal @container.content_type, 'action'
    end
  end

end

