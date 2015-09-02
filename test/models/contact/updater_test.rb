require 'test_helper'

class Contact::UpdaterTest < ActiveSupport::TestCase
  context 'update' do
    context 'policy allows update' do
      should 'update contact' do
        contact = mock()

        contact.expects(:update).once
        policy = stub(can_update?: true)
        params = {}

        Contact::Updater.new(contact, policy).update(params)
      end
    end
  end

  context 'policy allows update and params include empty password' do
    should 'remove password from params and update contact' do
      contact = mock()
      params = mock()

      contact.expects(:update).once
      policy = stub(can_update?: true)
      params.expects(:"[]").with(:password).returns('')
      params.expects(:delete).with(:password).once
      params.expects(:"[]").with(:image).returns(nil)

      Contact::Updater.new(contact, policy).update(params)
    end
  end

  context 'policy allows update but not image' do
    should 'remove image from params and update contact' do
      contact = mock()
      params = mock()

      contact.expects(:update).once
      policy = stub(can_update?: true, can_upload_image?: false)
      params.expects(:"[]").with(:password).returns(nil)
      params.expects(:"[]").with(:image).returns('anything_but_nil')
      params.expects(:delete).with(:image).once

      Contact::Updater.new(contact, policy).update(params)
    end
  end

  context 'policy does not allow update' do
    should 'add an error to contact' do
      contact = mock()

      contact.expects(:errors).once.returns(stub(:add))
      policy = stub(can_update?: false)
      params = {}

      Contact::Updater.new(contact, policy).update(params)
    end
  end
end
