require 'test_helper'

class Contact::CreatorTest < ActiveSupport::TestCase
  setup do
    create(:country) # Needed by new_contact. See example_data.rb.
    @contact = build(:contact, image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'))
  end

  context 'create' do
    context 'policy allows create and image' do
      setup do
        @policy = stub(can_create?: true, can_upload_image?: true)
      end

      should 'save contact and not set image nil' do
        assert_difference 'Contact.count', 1 do
          Contact::Creator.new(@contact, @policy).create
        end

        assert @contact.image?
      end
    end
  end

  context 'policy allows create but not image' do
    setup do
      @policy = stub(can_create?: true, can_upload_image?: false)
    end

    should 'save contact and set image nil' do
      assert_difference 'Contact.count', 1 do
        Contact::Creator.new(@contact, @policy).create
      end

      assert_not @contact.image?
    end
  end

  context 'policy does not allow create' do
    setup do
      @policy = stub(can_create?: false)
    end

    should 'add an error to contact' do
      assert_no_difference 'Contact.count' do
        Contact::Creator.new(@contact, @policy).create
      end

      assert_contains @contact.errors, 'You are not authorized to create that contact.'
    end
  end


  should "send a welcome email to new contacts from participant level organizations" do
    policy = stub(can_create?: true, can_upload_image?: false)
    organization = create(:organization, :participant_level, :active_participant)

    contact = build(:contact, organization: organization, username: "foo")
    service = Contact::Creator.new(contact, policy)

    assert_difference -> { ActionMailer::Base.deliveries.size }, +1 do
      assert service.create, contact.errors.full_messages
      email = ActionMailer::Base.deliveries.last
      assert_equal "Welcome to the UN Global Compact Academy", email.subject
    end
  end

end
