require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  context "given an organization that wants to sign up" do
    setup do
      create_organization_type
      create_country
      create_roles
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
      post :step3, :contact => {:first_name => 'Michael',
                                :last_name  => 'Smith',
                                :prefix     => 'Mr',
                                :job_title  => 'Job Title',
                                :phone      => '+1 416 1234567',
                                :address    => '123 Example Ave',
                                :city       => 'Toronto',
                                :country_id => Country.first.id,
                                :email      => 'michael@example.com',
                                :login      => 'username',
                                :password   => 'password'}
      assert_response :success
      assert_template 'step3'
    end

    should "business should get the fourth step page after posting ceo contact details" do
      
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc', :organization_type_id => OrganizationType.first.id)
      post :step4, :contact => {:first_name => 'CEO',
                                :last_name  => 'Smith',
                                :prefix     => 'Mr',
                                :job_title  => 'CEO',
                                :phone      => '+1 416 1234567',
                                :address    => '123 Example Ave',
                                :city       => 'Toronto',
                                :country_id => Country.first.id,
                                :email      => 'smith@example.com'}
      assert_response :success
      assert_template 'step4'
    end

    should "non-business should get the fifth step page after posting ceo contact details" do
      @non_business_organization_type = create_organization_type(:name => 'Academic', :type_property => OrganizationType::NON_BUSINESS)
      
      @organization, session[:signup_organization] = Organization.new(:name => 'ACME inc', :organization_type_id => @non_business_organization_type)
      post :step5, :contact => {:first_name => 'CEO',
                                :last_name  => 'Smith',
                                :prefix     => 'Mr',
                                :job_title  => 'CEO',
                                :phone      => '+1 416 1234567',
                                :address    => '123 Example Ave',
                                :city       => 'Toronto',
                                :country_id => Country.first.id,
                                :email      => 'smith@example.com'}
      assert_response :success
      assert_template 'step5'
    end

    
    should "get the fifth step page after posting ceo contact details" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id)
                                                       
      session[:signup_contact] = Contact.new(:first_name => 'First',
                                             :last_name  => 'Last',
                                             :prefix     => 'Mr',
                                             :job_title  => 'Job Title',
                                             :phone      => '+1 416 1234567',
                                             :address    => '123 Example Ave',
                                             :city       => 'Toronto',
                                             :country_id => Country.first.id,
                                             :email      => 'first@example.com',
                                             :login      => 'username',
                                             :password   => 'password',
                                             :role_ids   => [Role.contact_point.id])

      post :step5, :contact => {:first_name => 'CEO',
                                :last_name  => 'Smith',
                                :prefix     => 'Mr',
                                :job_title  => 'CEO',
                                :phone      => '+1 416 1234567',
                                :address    => '123 Example Ave',
                                :city       => 'Toronto',
                                :country_id => Country.first.id,
                                :email      => 'smith@example.com'}
      assert_response :success
      assert_template 'step5'
    end
    
    should "get the sixth step page after submitting letter of commitment" do
      session[:signup_organization] = Organization.new(:name                 => 'ACME inc',
                                                       :organization_type_id => OrganizationType.first.id,
                                                       :employees            => 500)
      session[:signup_contact] = Contact.new(:first_name => 'First',
                                             :last_name  => 'Last',
                                             :prefix     => 'Mr',
                                             :job_title  => 'Job Title',
                                             :phone      => '+1 416 1234567',
                                             :address    => '123 Example Ave',
                                             :city       => 'Toronto',
                                             :country_id => Country.first.id,
                                             :email      => 'first@example.com',
                                             :login      => 'username',
                                             :password   => 'password',
                                             :role_ids   => [Role.contact_point.id])
      session[:signup_ceo] = Contact.new(:first_name => 'CEO',
                                         :last_name  => 'Last',
                                         :prefix     => 'Mr',
                                         :job_title  => 'CEO',
                                         :phone      => '+1 416 1234567',
                                         :address    => '123 Example Ave',
                                         :city       => 'Toronto',
                                         :country_id => Country.first.id,
                                         :role_ids   => [Role.ceo.id],
                                         :email      => 'smith@example.com')
      assert_emails(1) do
        assert_difference 'Organization.count' do
          assert_difference 'Contact.count', 2 do
            post :step6, :organization => {:commitment_letter => fixture_file_upload('files/untitled.pdf', 'application/pdf')}
          end
        end
      end
      assert_response :success
      assert_template 'step6'
    end
  end  
end
