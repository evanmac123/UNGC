require 'test_helper'

class ParticipantSearchControllerTest < ActionController::TestCase
  setup do
    Container.stubs(by_path: stub(first!: container))
  end

  context 'the search form' do

    setup do
      ParticipantSearchForm.any_instance.expects(:execute).returns([])
      get :index
    end

    should 'assign a page' do
      assert_not_nil assigns(:page)
    end

    should 'assign a search object' do
      assert_not_nil assigns(:search)
    end

    should 'be successful' do
      assert_response :success
    end

  end

  context 'searching' do

    setup do
      @args = {'organization_types' => ['123']}

      form = ParticipantSearchForm.new(1, @args)
      form.stubs(execute: [])

      ParticipantSearchForm.expects(:new)
        .with(1, @args)
        .returns(form)
    end

    should 'assign a page' do
      search
      assert_not_nil assigns(:page)
    end

    should 'assign a search object' do
      search
      assert_not_nil assigns(:search)
    end

    should 'be successful' do
      search
      assert_response :success
    end

    should 'create a search with the params provided' do
      search
    end

  end

  private

  def search
    get :search, search: @args
  end

  def container
    @container ||= create(:container)
  end

end
