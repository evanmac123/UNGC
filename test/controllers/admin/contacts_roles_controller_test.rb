require 'test_helper'

class Admin::ContactsRolesControllerTest < ActionController::TestCase

  setup {
    create(:country)
    create_staff_user
    @contact = create(:contact)
    @role = create(:role)

    sign_in @staff_user
    request.env["HTTP_REFERER"] = '/admin'
  }

  test "add @role to contact" do

    assert_difference '@contact.roles.count', +1 do
      post :create, contact_id: @contact, role_id: @role
    end

    assert_redirected_to '/admin'
  end

  test 'remove role from contact' do
    @contact.roles << @role
    @contact.save!

    assert_difference '@contact.roles.count', -1 do
      # id is a fake reference to the non existent contacts_roles model
      delete :destroy, id: 1, contact_id: @contact, role_id: @role
    end

    assert_redirected_to '/admin'
  end

end
