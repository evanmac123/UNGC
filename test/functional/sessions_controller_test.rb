require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    create_roles
    create_test_users
  end

  def test_should_login_and_redirect
    post :create, :login => 'quentin', :password => 'monkey'
    assert session[:user_id]
    assert_response :redirect
  end

  def test_should_fail_login_and_not_redirect
    post :create, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user_id]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :destroy
    assert_nil session[:user_id]
    assert_response :redirect
  end

  def test_should_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'quentin', :password => 'monkey', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    @request.cookies["auth_token"] = nil
    post :create, :login => 'quentin', :password => 'monkey', :remember_me => "0"
    assert @response.cookies["auth_token"].blank?
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :destroy
    assert @response.cookies["auth_token"].blank?
  end

  def test_should_login_with_cookie
    @contact.remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_expired_cookie_login
    @contact.remember_me
    @contact.update_attribute :remember_token_expires_at, 5.minutes.ago
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :new
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    @contact.remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :new
    assert !@controller.send(:logged_in?)
  end

  protected
    def create_test_users
      create_organization_type
      create_organization_and_ceo
      create_country
      @contact = create_contact(:login => 'quentin',
                                :password => 'monkey',
                                :email => 'user@example.com',
                                :remember_token_expires_at => 1.days.from_now.to_s,
                                :remember_token => '77de68daecd823babbb58edb1c8e14d7106e83bb',
                                :role_ids => [Role.contact_point.id])
    end
  
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token @contact.remember_token
    end
end
