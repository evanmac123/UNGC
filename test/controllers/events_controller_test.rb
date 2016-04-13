require 'test_helper'

class EventsControllerTest < ActionController::TestCase
  setup do
    create(:container, path: '/take-action/events')

    EventsListForm.any_instance.stubs(execute: MockSearchResult.new)

    @event = create(:event,
      starts_at: Time.new(2015, 7, 25, 11, 0, 0),
      ends_at: Time.new(2015, 7, 26, 2, 0, 0)
    )
    @event.approve!
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:search)
    assert_not_nil assigns(:page)
  end

  test 'should get show' do
    get :show, id: @event

    assert_response :success
    assert_not_nil assigns(:page)
  end
end
