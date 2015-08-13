require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  setup do
    create_container path: '/news'
    create_container path: '/news/press-releases'

    NewsListForm.any_instance.stubs(execute: MockSearchResult.new)

    @headline = create_headline
    @headline.approve!
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:page)
  end

  test 'should get show' do
    get :show, id: @headline

    assert_response :success
    assert_not_nil assigns(:page)
  end

  test 'should get press releases' do
    get :press_releases

    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:page)
  end
end
