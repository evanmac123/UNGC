require 'test_helper'

class FakeValidator
  def initialize(data)
  end

  def valid?
    true
  end
end

class ContainerDraftTest < ActiveSupport::TestCase

  context '#save' do

    setup do
      @container = create(:container)
      @container.payload_validator = FakeValidator
      @container.draft_payload = create(:payload,
        container: @container,
        json_data: {
          meta_tags: {
            content_type: 0
          }
        }.deep_stringify_keys.to_json
      )
      @container.save
      @staff_user = create_staff_user
      @draft = ContainerDraft.new(@container, @staff_user)
    end

    should 'save valid payloads' do
      assert @draft.save(valid_payload_attributes)
    end

    should 'be updated by the staff user' do
      assert @draft.save(valid_payload_attributes)
      assert_equal @staff_user, @container.draft_payload.updated_by
    end

    should 'mark the container as having a draft' do
      @container.has_draft = false
      assert @draft.save(valid_payload_attributes)
      assert @container.has_draft
    end

=begin

    should "reset approval status to pending if draft payload is different than public payload on updat" do
      @container.public_payload = create(:payload,
        container_id: @container.id,
        json_data: {
          meta_tags: {
            content_type: 1
          }
        }.deep_stringify_keys.to_json
      )
      @container.approve!
      @container.draft_payload = create(:payload,
        container_id: @container.id,
        json_data: {
          meta_tags: {
            content_type: 0
          }
        }.deep_stringify_keys.to_json
      )
      @container.save

      updater = Container::Updater.new(@container)
      updater.update({})
      assert_equal @container.approval, 'pending'
    end
=end
  end
end
