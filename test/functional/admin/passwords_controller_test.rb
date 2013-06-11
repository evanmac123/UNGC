require 'test_helper'

class Admin::PasswordsControllerTest < ActionController::TestCase
  VALID_TOKEN = 'this_is_a_token'
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

    should "get an error when posting invalid email address" do
      post :create, :contact => {:email => 'invalid@example.com'}
      assert_response :success
      assert_not_nil flash[:error]
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
      @financial_contact = create_contact(:organization_id => @organization.id,
                                          :email           => 'finance@example.com',
                                          :role_ids        => [Role.financial_contact.id])
      @financial_contact.roles.delete(Role.contact_point)
      @financial_contact.username, @financial_contact.plaintext_password = nil
      @financial_contact.save
    end

    should "not get an email even when posting a valid email address" do
      assert_no_difference 'ActionMailer::Base.deliveries.size' do
        post :create, :contact => {:email => @financial_contact.email}
        assert_response :success
        assert_not_nil flash[:error]
      end
    end


    context "with a token" do
      setup do
        @organization_user.update_attribute :reset_password_token, VALID_TOKEN
        @organization_user.update_attribute :reset_password_sent_at, Time.now
      end

      should "get to the edit page with a valid token" do
        get :edit, :reset_password_token => VALID_TOKEN
        assert_response :success
      end

      should "change the password" do
        put :update, :contact => {
          :reset_password_token   => VALID_TOKEN,
          :password               => 'password',
          :password_confirmation  => 'password'
        }

        assert_response :redirect
        assert_not_nil flash[:notice]
        # plain passwords are still saved, so we can still check this:
        assert_equal 'password', @organization_user.reload.plaintext_password
      end

      should "not change the password with different passwords" do
        put :update, :contact => {
          :reset_password_token   => VALID_TOKEN,
          :password               => 'password_1',
          :password_confirmation  => 'password_2'
        }

        assert_select "div#error_explanation"
        assert_response :success
      end

      should "not change the password with a blank password" do
        put :update, :contact => {
          :reset_password_token   => VALID_TOKEN,
          :password               => '',
          :password_confirmation  => ''
        }

        assert_select "div#error_explanation"
        assert_response :success
      end
    end
  end
end
