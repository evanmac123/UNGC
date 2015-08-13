require 'test_helper'

class ContainerPublisherTest < ActiveSupport::TestCase

  setup do
    @staff_user = create_staff_user
  end

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

      # sectors
      sector1   = create_sector name: 'sector1'
      sector2  = create_sector name: 'sector2'

      # create a container with a draft payload including tags
      container = create_container
      container.draft_payload = create_payload(
        container_id: container.id,
        json_data: {
          taggings: {
            issues: [water.id, wind.id],
            topics: [fire.id, jello.id],
            sector: []
          }
        }.deep_stringify_keys.to_json
      )

      # start the container with some tags
      Tagging.create! container: container, issue: water
      Tagging.create! container: container, issue: earth
      Tagging.create! container: container, topic: fire
      Tagging.create! container: container, topic: slush
      Tagging.create! container: container, sector: sector1
      Tagging.create! container: container, sector: sector2

      publisher = ContainerPublisher.new(container, @staff_user)
      publisher.publish

      tags = Tagging.where(container: container).includes(:issue).includes(:topic)
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

    should "remove old tags if new tag array is empty" do
      assert_not_includes @tag_names, 'sector1'
      assert_not_includes @tag_names, 'sector2'
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
            content_type: 2
          }
        }.deep_stringify_keys.to_json
      )

    end

    should "apply the content_type" do
      assert_equal @container.content_type, 'default'
      publisher = ContainerPublisher.new(@container, @staff_user)
      publisher.publish
      assert_equal @container.content_type, 'action'
    end
  end

  context 'approved_by' do

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

    should "set the user that published" do
      publisher = ContainerPublisher.new(@container, @staff_user)
      assert_equal @container.has_draft, true
      publisher.publish
      assert_equal @container.public_payload.updated_by, @staff_user
      assert_equal @container.public_payload.approved_by, @staff_user
      assert_equal @container.has_draft, false
    end
  end

end
