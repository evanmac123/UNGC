require 'test_helper'

class Admin::CopQuestionsControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    create_principle_area
    @cop_question = create_cop_question

    login_as @staff_user
  end

  test "should get index" do
    get :index, {}
    assert_response :success
    assert_not_nil assigns(:cop_questions)
  end

  test "should get new" do
    get :new, {}
    assert_response :success
  end

  test "should create COP question" do
    assert_difference('CopQuestion.count') do
      post :create, :cop_question => { :text     => 'this is a question',
                                       :grouping => 'notable',
                                       :position => 1}
    end

    assert_redirected_to admin_cop_questions_path
  end

  test "should get edit" do
    get :edit, :id => @cop_question.to_param
    assert_response :success
  end

  test "should update COP question" do
    put :update, :id => @cop_question.to_param, :cop_question => { }
    assert_redirected_to admin_cop_questions_path
  end

  test "should destroy COP question" do
    assert_difference('CopQuestion.count', -1) do
      delete :destroy, :id => @cop_question.to_param
    end

    assert_redirected_to admin_cop_questions_path
  end
end
