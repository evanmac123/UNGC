require 'test_helper'

class RoleTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_belong_to :initiative

  context "find role by name" do
    setup do
      @role = create_role :name => 'Financial Contact'
    end

    should "find Financial Contact" do
      assert Role.financial_contact
    end
  end
   
end