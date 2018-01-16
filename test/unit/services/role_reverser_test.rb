require 'test_helper'

class RoleReverserTest < ActiveSupport::TestCase

  setup do
    create_organization_and_user

    @old_ceo = create(:ceo_contact,
      organization: @organization,
    )

    @old_cp = create(:contact,
      password: 'i-am-Contact-point-123',
      organization: @organization,
      roles: [Role.contact_point]
    )

    @result = RoleReverser.reverse(ceo: @old_ceo, contact_point: @old_cp)
    @new_ceo = Contact.find(@old_cp.id)
    @new_cp = Contact.find(@old_ceo.id)
  end

  should 'have succeeded' do
    assert @result, 'failed to reverse roles'
  end

  context 'the new CEO' do
    should 'be the old contact point' do
      assert_equal @new_ceo.id, @old_cp.id
    end

    should 'be a CEO' do
      assert @new_ceo.is? Role.ceo
    end

    should 'no longer be a contact point' do
      refute @new_ceo.is? Role.contact_point
    end

    should 'no longer be able to log in' do
      refute @new_ceo.valid_password? 'i-am-Contact-point-123'
      refute @new_ceo.valid_password? nil
    end

  end

  context 'the new contact point' do
    should 'be the old CEO' do
      assert_equal @new_cp.id, @old_ceo.id
    end

    should 'no longer be a CEO' do
      refute @new_cp.is? Role.ceo
    end

    should 'be a contact point' do
      assert @new_cp.is? Role.contact_point
    end

    should 'be able to login with the old contact points password' do
      assert @new_cp.valid_password? 'i-am-Contact-point-123'
    end
  end

end
