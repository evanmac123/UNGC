require 'test_helper'

class Contact::CreatorTest < ActiveSupport::TestCase
  setup do
    create_country # Needed by new_contact. See example_data.rb.
    @contact = new_contact(image: fixture_file_upload('files/untitled.jpg', 'image/jpeg'))
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

        assert @contact.image, true
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

      assert @contact.image, nil
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

      assert_equal @contact.errors.count, 1
      assert_equal @contact.errors[:base].first, 'You are not authorized to create that contact.'
    end
  end
end
