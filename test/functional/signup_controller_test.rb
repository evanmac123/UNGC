require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  context "given an organization that wants to sign up" do
    setup do
      create_organization_type
      create_country
      create_roles
      
      @contact = {:first_name => 'Michael',
                  :last_name  => 'Smith',
                  :prefix     => 'Mr',
                  :job_title  => 'Job Title',
                  :phone      => '+1 416 1234567',
                  :address    => '123 Example Ave',
                  :city       => 'Toronto',
                  :country_id => Country.first.id,
                  :email      => 'michael@example.com',
                  :login      => 'username',
                  :password   => 'password',
                  :role_ids   => [Role.contact_point.id]}
                  
      @ceo = {:first_name => 'CEO',
              :last_name  => 'Smith',
              :prefix     => 'Mr',
              :job_title  => 'CEO',
              :phone      => '+1 416 1234567',
              :address    => '123 Example Ave',
              :city       => 'Toronto',
              :country_id => Country.first.id,
              :email      => 'smith@example.com',
              :role_ids   => [Role.ceo.id]}

      @financial_contact = {:first_name => 'Michael',
                            :last_name  => 'Smith',
                            :prefix     => 'Mr',
                            :job_title  => 'Accountant',
                            :phone      => '+1 416 1234567',
                            :address    => '123 Example Ave',
                            :city       => 'Toronto',
                            :country_id => Country.first.id,
                            :email      => 'michael@example.com',
                            :role_ids   => [Role.financial_contact.id]}
      
    end
    
    should "get the first step page" do
      get :step1, :org_type => 'business'
      assert_response :success
    end

    should "get the second step page after posting organization details" do
      post :step2, :organization => {:name      => 'ACME inc',
                                     :employees => 500,
                                     :url       => 'http://www.example.com',
                                     :organization_type_id => OrganizationType.first.id}
      assert_response :success
      assert_template 'step2'
    end
    
    should "get the third step page after posting contact details" do
      post :step3, :contact => @contact
      assert_response :success
      assert_template 'step3'
    end

    should "business should get the fourth step page after posting ceo contact details" do      
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc',
                                                                      :organization_type_id => OrganizationType.first.id)
      post :step4, :contact => @ceo
      assert_response :success
      assert_template 'step4'
    end

    should "non-business should get the sixth step page after posting ceo contact details" do
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc',
                                                                      :organization_type_id => @non_business_organization_type)
      post :step4, :contact => @ceo
      assert_redirected_to organization_step6_path
    end
    
    should "business should get the fifth step page after selecting a contribution amount" do
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc', :organization_type_id => OrganizationType.first.id)
      post :step5, :organization => {:pledge_amount => 2000}
      assert_response :success
      assert_template 'step5'
    end

    should "business should get the sixth step page if they don't select a contribution amount" do
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc', :organization_type_id => OrganizationType.first.id)
      post :step5
      assert_redirected_to organization_step6_path
    end

    should "non-business should get the sixth step page after posting ceo contact details" do
      @non_business_organization_type = create_organization_type(:name => 'Academic', :type_property => OrganizationType::NON_BUSINESS)
      
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc', :organization_type_id => @non_business_organization_type)
      session[:signup_contact] = Contact.new(@contact)
      
      post :step6, :contact => @ceo
      assert_response :success
      assert_template 'step6'
    end

    should "get the sixth step page after posting ceo contact details" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id)
      session[:signup_contact] = Contact.new(@contact)
      post :step6, :contact => @ceo

      assert_response :success
      assert_template 'step6'
    end
    
    should "get the seventh step page after submitting letter of commitment" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id,
                                                       :employees            => 500)
      session[:signup_contact] = Contact.new(@contact)
      session[:signup_ceo] = Contact.new(@ceo)
      session[:financial_contact] = Contact.new(@financial_contact)
      assert_emails(1) do
        assert_difference 'Organization.count' do
          assert_difference 'Contact.count', 3 do
            post :step7, :organization => {:commitment_letter => fixture_file_upload('files/untitled.pdf', 'application/pdf')}
          end
        end
      end
      assert_response :success
      assert_template 'step7'
    end 
    
  end
end
