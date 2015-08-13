require 'test_helper'

class ActionsControllerTest < ActionController::TestCase
  setup do
    create_container path: '/take-action/action'

    WhatYouCanDoForm.any_instance.stubs(execute: MockSearchResult.new)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:page)
  end
end
