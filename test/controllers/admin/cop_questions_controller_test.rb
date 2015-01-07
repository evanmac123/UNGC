require 'test_helper'

class Admin::CopQuestionsControllerTest < ActionController::TestCase
  def setup
    @staff_user = create_staff_user
    create_principle_area
    @cop_question = create_cop_question

    sign_in @staff_user
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

  context "question filtering" do
    setup do
      @question_2010 = create_cop_question year: 2010
      @question_2014 = create_cop_question year: 2014
    end

    should "show all when no year param is given" do
      get :index
      questions = assigns(:cop_questions)
      assert_equal [@cop_question, @question_2010, @question_2014], questions
    end

    should "show question without a value for year when 'no_year' is given" do
      get :index, year: 'no_year'
      questions = assigns(:cop_questions)
      assert_equal [@cop_question], questions
    end

    should "should questions for a given year when a year is given" do
      get :index, year: 2010
      questions = assigns(:cop_questions)
      assert_equal [@question_2010], questions
    end

  end
end
