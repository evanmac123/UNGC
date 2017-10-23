require 'test_helper'

class IglooUserTest < ActiveSupport::TestCase

  test "deleting a contact destroy's the igloo user" do
    contact = create(:contact)
    create(:igloo_user, contact: contact)

    assert_difference -> { IglooUser.count }, -1 do
      contact.destroy
    end
  end

end
