require 'test_helper'

class ContainerPublisherTest < ActiveSupport::TestCase
  setup do
    @staff_user = create_staff_user
  end

  context 'tags' do
    setup do
      issue_1  = create_issue name: 'Issue 1'
      issue_2  = create_issue name: 'Issue 2'
      issue_3   = create_issue name: 'Issue 3'
      topic_1   = create_topic name: 'Topic 1'
      topic_2  = create_topic name: 'Topic 2'
      topic_3  = create_topic name: 'Topic 3'
      sector_1   = create_sector name: 'Sector 1'
      sector_2  = create_sector name: 'Sector 2'
      sdg_1 = create_sustainable_development_goal name: 'Sustainable Development Goal 1'

      # Create a container with some tags
      container = create_container
      Tagging.create! container: container, issue: issue_1
      Tagging.create! container: container, issue: issue_2
      Tagging.create! container: container, topic: topic_1
      Tagging.create! container: container, topic: topic_2
      Tagging.create! container: container, sector: sector_1
      Tagging.create! container: container, sector: sector_2
      Tagging.create! container: container, sustainable_development_goal: sdg_1

      # Add a draft payload with updated tags
      container.draft_payload = create_payload(
        container_id: container.id,
        json_data: {
          taggings: {
            issues: [issue_1.id, issue_3.id],
            topics: [topic_1.id, topic_3.id],
            sector: [],
            sustainable_development_goals: [sdg_1.id]
          }
        }.deep_stringify_keys.to_json
      )

      # Publish draft payload
      publisher = ContainerPublisher.new(container, @staff_user)
      publisher.publish

      tags = Tagging.where(container: container).includes(:issue).includes(:topic)
      @tag_names = tags.map {|t| t.domain.name}
    end

    should 'include new tags' do
      assert_includes @tag_names, 'Issue 3'
      assert_includes @tag_names, 'Topic 3'
    end

    should 'include unchanged tags' do
      assert_includes @tag_names, 'Issue 1'
      assert_includes @tag_names, 'Topic 1'
      assert_includes @tag_names, 'Sustainable Development Goal 1'
    end

    should 'not include removed tags' do
      assert_not_includes @tag_names, 'Issue 2'
      assert_not_includes @tag_names, 'Topic 2'
    end

    should 'not include tags if new tag array is empty' do
      assert_not_includes @tag_names, 'Sector 1'
      assert_not_includes @tag_names, 'Sector 2'
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

    should 'apply the content_type' do
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

    should 'set the user that published' do
      publisher = ContainerPublisher.new(@container, @staff_user)
      assert_equal @container.has_draft, true
      publisher.publish
      assert_equal @container.public_payload.updated_by, @staff_user
      assert_equal @container.public_payload.approved_by, @staff_user
      assert_equal @container.has_draft, false
    end
  end

end
