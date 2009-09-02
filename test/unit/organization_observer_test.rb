require 'test_helper'

class OrganizationObserverTest < ActiveSupport::TestCase
  def setup
    @observer = OrganizationObserver.instance
    @organization = create_organization
    @organization.contacts.create(:email      => 'dude@example.com',
                                  :first_name => 'a',
                                  :last_name  => 'b')
  end

  test "email is sent after organization is submitted" do
    assert_emails 1 do
      @observer.after_submit(@organization, nil)
    end
  end
end
