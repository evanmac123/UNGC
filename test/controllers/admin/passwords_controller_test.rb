require 'test_helper'

class Admin::PasswordsControllerTest < ActionController::TestCase
  INVALID_TOKEN = 'NOT_A_TOKEN'

  def setup
    request.env['devise.mapping'] = Devise.mappings[:contact]
  end

  context "given an existing user" do
    setup do
      create_organization_and_ceo
    end

    should "get the reset password page" do
      get :new
      assert_response :success
    end

    should "get an email when posting a valid email address" do
      assert_difference 'ActionMailer::Base.deliveries.size' do
        post :create, :contact => {:email => @organization_user.email}
        assert_not_nil flash[:notice]
        assert_redirected_to new_contact_session_path
        assert_not_nil @organization_user.reload.reset_password_token
      end
    end

  end

  context "given a user with no login information" do
    setup do
      create_organization_and_ceo
      @financial_contact = create(:contact, :financial_contact, organization_id: @organization.id,
                                  email: 'finance@example.com')
      @financial_contact.roles.delete(Role.contact_point)
      @financial_contact.username, @financial_contact.password = nil
      @financial_contact.save
    end

    should "not get an email even when posting a valid email address" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post :create, :contact => { :email => @financial_contact.email }
        assert_response :redirect
        assert_not_nil flash[:notice]
      end
    end


    context "with a token" do
      setup do
        @reset_token = @organization_user.send_reset_password_instructions
      end

      should "get to the edit page with a valid token" do
        get :edit, :reset_password_token => @reset_token
        assert_response :success
      end

      should "change the password" do
        put :update, :contact => {
          :reset_password_token   => @reset_token,
          :password               => 'NewPassw0rd',
          :password_confirmation  => 'NewPassw0rd'
        }

        assert_response :redirect
        assert_not_nil flash[:notice]

        contact = @organization_user.reload
        assert_not_nil contact.encrypted_password
        assert contact.valid_password? 'NewPassw0rd'
      end

      should "not change the password with different passwords" do
        put :update, :contact => {
          :reset_password_token   => @reset_token,
          :password               => 'Passw0rd',
          :password_confirmation  => 'OtherPassw0rd'
        }

        assert_select "div#error_explanation"
        assert_response :success
      end

      should "not change the password with a blank password" do
        put :update, :contact => {
          :reset_password_token   => @reset_token,
          :password               => '',
          :password_confirmation  => ''
        }

        assert_select "div#error_explanation"
        assert_response :success
      end
    end
  end
end
