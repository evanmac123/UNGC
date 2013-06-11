require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    create_roles
    create_test_users
    @request.env['devise.mapping'] = Devise.mappings[:contact]
  end

context "given an organization user" do

  should "login and redirect" do
    post :create, :contact => {:username => 'quentin', :password => 'monkey'}
    assert_response :redirect
    assert @controller.current_contact
    assert_equal "Welcome. You have been logged in.", flash[:notice]
  end

  should "login and redirect to edit screen if last login was over 6 months ago" do
    post :create, :contact => {:username => 'login', :password => 'nexen'}
    assert @controller.contact_signed_in?
    assert_redirected_to edit_admin_organization_contact_path(@old_contact.organization.id, @old_contact, {:update => true})
  end

  should 'not allow rejected applicants to login' do
    @organization.reject
    post :create, :contact => {:username => 'quentin', :password => 'monkey'}
    assert_equal "Sorry, your organization's application was rejected and can no longer be accessed.", flash[:error]
    assert_nil flash[:notice]
    assert_response :redirect
  end

  should 'fail login and not redirect' do
    post :create, :contact => {:username => 'quentin', :password => 'bad password'}
    assert_match /username or password was incorrect/, flash[:alert]
    assert !@controller.contact_signed_in?
    assert_response :success
  end

  should 'logout' do
    sign_in @contact
    delete :destroy
    assert_response :redirect
  end

  should 'remember me' do
    @request.cookies["remember_contact_token"] = nil
    post :create, :contact => {:username => 'quentin', :password => 'monkey', :remember_me => "1"}
    assert_not_nil @response.cookies["remember_contact_token"]
  end

  should 'not remember me' do
    @request.cookies["remember_contact_token"] = nil
    post :create, :contact => {:username => 'quentin', :password => 'monkey', :remember_me => "0"}
    assert @response.cookies["remember_contact_token"].blank?
  end

  should 'delete token on logout' do
    sign_in @contact
    delete :destroy
    assert @response.cookies["remember_contact_token"].blank?
  end

  should 'login with cookie' do
    @contact.remember_me!
    @request.cookies["remember_contact_token"] = cookie_for(@contact)
    get :new
    assert @controller.send(:current_contact)
  end

  should 'fail expired cookie login' do
    @contact.remember_me!
    @contact.update_attribute :remember_created_at, 3.weeks.ago
    @request.cookies["remember_contact_token"] = cookie_for(@contact)
    get :new
    assert !@controller.send(:current_contact)
  end

  should 'fail cookie login' do
    @contact.remember_me
    @request.cookies["remember_contact_token"] = 'invalid_auth_token'
    get :new
    assert !@controller.send(:current_contact)
  end

end

  protected
    def create_test_users
      create_organization_type
      create_organization_and_ceo
      create_country
      @contact = create_contact(
        :organization_id => @organization.id,
        :username => 'quentin',
        :password => 'monkey',
        :email => 'user@example.com',
        :remember_token_expires_at => 1.days.from_now.to_s,
        :remember_token => '77de68daecd823babbb58edb1c8e14d7106e83bb',
        :role_ids => [Role.contact_point.id]
      )

      @old_contact = create_contact(
        :organization_id => @organization.id,
        :username => 'login',
        :password => 'nexen',
        :email => 'user2@example.com',
        :last_sign_in_at => 7.months.ago,
        :role_ids => [Role.contact_point.id]
      )
    end

    def cookie_for(contact)
      raw_cookie = Contact.serialize_into_cookie(contact).tap { |a| a.last << '' }
      cookies['remember_contact_token'] = generate_signed_cookie(raw_cookie)
    end

    def generate_signed_cookie(raw_cookie)
      request = ActionDispatch::TestRequest.new
      request.cookie_jar.signed['raw_cookie'] = raw_cookie
      request.cookie_jar['raw_cookie']
    end

end
