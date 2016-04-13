require 'test_helper'

class Contact::UpdaterTest < ActiveSupport::TestCase
  setup do
    create(:country) # Needed by create_contact. See example_data.rb.
    @contact = create(:contact, password: 'password')
  end

  context 'update' do
    context 'policy allows update' do
      setup do
        @policy = stub(can_update?: true)
        @params = {}
      end

      should 'update contact' do
        assert Contact::Updater.new(@contact, @policy).update(@params)
      end
    end

    context 'policy allows update and params include empty password' do
      setup do
        @policy = stub(can_update?: true)
        @params = { password: '' }
      end

      should 'update contact but not set password' do
        assert Contact::Updater.new(@contact, @policy).update(@params)
        assert_equal 'password', @contact.password
      end
    end

    context 'policy allows update but not image' do
      setup do
        @policy = stub(can_update?: true, can_upload_image?: false)
        @params = { image: fixture_file_upload('files/untitled.jpg', 'image/jpeg') }
        Contact::Updater.new(@contact, @policy).update(@params)
      end

      should 'update contact but not set image' do
        assert Contact::Updater.new(@contact, @policy).update(@params)
        assert_not @contact.image?
      end
    end

    context 'policy does not allow update' do
      setup do
        @policy = stub(can_update?: false)
        @params = {}
      end

      should 'not update contact and instead add an error to contact' do
        assert_not Contact::Updater.new(@contact, @policy).update(@params)
        assert_equal @contact.errors[:base].first, 'You are not authorized to edit that contact.'
      end
    end
  end
end
