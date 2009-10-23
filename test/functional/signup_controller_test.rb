require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  context "given an organization that wants to sign up" do
    setup do
      create_organization_type
      create_roles
    end
    
    should "get the first step page" do
      get :step1, :org_type => 'business'
      assert_response :success
    end

    should "get the second step page after posting organization details" do
      post :step2, :organization => {:name => 'ACME inc', :employees => 500}
      assert_response :success
      assert_template 'step2'
    end
    
    should "get the third step page after posting contact details" do
      post :step3, :contact => {:first_name => 'Michael', :last_name => 'Smith'}
      assert_response :success
      assert_template 'step3'
    end
    
    should "get the fourth step page after posting ceo contact details" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id)
      post :step4, :contact => {:first_name => 'CEO', :last_name => 'Smith'}
      assert_response :success
      assert_template 'step4'
    end
    
    should "get the fifth step page after submitting letter of commitment" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id,
                                                       :employees            => 500)
      assert_emails(1) do
        assert_difference 'Organization.count' do
          post :step5, :organization => {:commitment_letter => fixture_file_upload('files/untitled.pdf', 'application/pdf')}
        end
      end
      assert_response :success
      assert_template 'step5'
    end
  end
end
