require 'test_helper'

class Contact::CreatorTest < ActiveSupport::TestCase
  context 'create' do
    context 'policy allows create and image' do
      should 'save contact and not set image nil' do
        contact = mock()

        contact.expects(:save).once
        contact.expects(:image=).never

        policy = stub(can_create?: true, can_upload_image?: true)

        Contact::Creator.new(contact, policy).create
      end
    end
  end

  context 'policy allows create but not image' do
    should 'save contact and set image nil' do
      contact = mock()

      contact.expects(:save).once
      contact.expects(:image=).once.with(nil)

      policy = stub(can_create?: true, can_upload_image?: false)

      Contact::Creator.new(contact, policy).create
    end
  end

  context 'policy does not allow create' do
    should 'add an error to contact' do
      contact = mock()

      contact.expects(:errors).once.returns(stub(:add))

      policy = stub(can_create?: false)

      Contact::Creator.new(contact, policy).create
    end
  end
end
