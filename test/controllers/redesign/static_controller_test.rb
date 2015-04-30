require 'test_helper'

class Redesign::StaticControllerTest < ActionController::TestCase
  setup do
    create_staff_user
    sign_in @staff_user
  end

  context '#catch_all' do
    should 'throw and error when the path does not resolve a container' do
      assert_raise ActiveRecord::RecordNotFound do
        get :catch_all, path: '/herp/i/dont/exist'
      end
    end

    should 'resolve a container that exists with the provided path' do
      container = Redesign::Container.create!(
        path: '/i/am/exist',
        layout: :article
      )

      get :catch_all, path: '/I/Am/Exist/'

      assert_response :success
      assert_equal container.id, @controller.send(:current_container).id
      assert_not_nil assigns(:page)
      assert_template :article
    end
  end
end
