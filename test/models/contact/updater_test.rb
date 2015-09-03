require 'test_helper'

class Contact::UpdaterTest < ActiveSupport::TestCase
  setup do
    create_country # Needed by create_contact. See example_data.rb.
    @contact = create_contact(
      username: 'venu',
      password: 'password'
    )
  end

  context 'update' do
    context 'policy allows update' do
      setup do
        policy = stub(can_update?: true)
        params = { username: 'keesari' }
        Contact::Updater.new(@contact, policy).update(params)
      end

      should 'update contact' do
        assert_equal 'keesari', @contact.username
      end
    end
  end

  context 'policy allows update and params include empty password' do
    setup do
      policy = stub(can_update?: true)
      params = { username: 'keesari', password: '' }
      Contact::Updater.new(@contact, policy).update(params)
    end

    should 'remove password from params' do
      assert_equal 'password', @contact.password
    end

    should 'update contact' do
      assert_equal 'keesari', @contact.username
    end
  end

  context 'policy allows update but not image' do
    setup do
      policy = stub(can_update?: true, can_upload_image?: false)
      params = { username: 'keesari', image: fixture_file_upload('files/untitled.jpg', 'image/jpeg') }
      Contact::Updater.new(@contact, policy).update(params)
    end

    should 'not set image' do
      assert_not @contact.image?
    end

    should 'update contact' do
      assert_equal 'keesari', @contact.username
    end
  end

  context 'policy does not allow update' do
    setup do
      policy = stub(can_update?: false)
      params = { username: 'keesari' }
      Contact::Updater.new(@contact, policy).update(params)
    end

    should 'add an error to contact' do
      assert_equal @contact.errors[:base].first, 'You are not authorized to edit that contact.'
    end
  end
end
