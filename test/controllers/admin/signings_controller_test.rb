require 'test_helper'

class Admin::SigningsControllerTest < ActionController::TestCase
  context "given an existing initiative" do
    setup do
      create_organization_and_user
      @initiative = create(:initiative)
      sign_in create_staff_user
    end

    should "add a signatory by posting to create" do
      assert_difference '@initiative.signings.count' do
        post :create, :initiative_id => @initiative.id,
                      :signing       => {:organization_id => @organization.id,
                                         :added_on        => Date.current}
        assert_response :redirect
      end
    end
  end

  context "given an existing initiative and a signatory" do
    setup do
      create_organization_and_user
      @initiative = create(:initiative)
      @signatory = create(:signing, :initiative_id   => @initiative.id,
                                  :organization_id => @organization.id)
      sign_in create_staff_user
    end

    should "remove the signatory by posting to destroy" do
      assert_difference '@initiative.signings.count', -1 do
        delete :destroy, :initiative_id => @initiative.id,
                         :id            => @signatory.id
        assert_response :redirect
      end
    end

    should "not add the same organization twice" do
      assert_difference '@initiative.signings.count', 0 do
        post :create, :initiative_id => @initiative.id,
                      :signing       => {:organization_id => @organization.id,
                                         :added_on        => Date.current}
      end
    end
  end

end
