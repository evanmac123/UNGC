require 'test_helper'

class CopQuestionTest < ActiveSupport::TestCase
  should validate_presence_of :text
  should have_many :cop_attributes
  should belong_to :principle_area
  should belong_to :initiative

  context "given an organization in no initiatives" do
    setup do
      init_data
    end

    should "only have generic questions in its list" do
      assert_equal 2, CopQuestion.questions_for(@organization).size
      assert !CopQuestion.questions_for(@organization).include?(CopQuestion.find_by_position(3))
    end
  end

  context "given an organization with 1 initiave" do
    setup do
      init_data(true)
    end

    should "have initiative specific questions in its list" do
      assert_equal 3, CopQuestion.questions_for(@organization).size
      assert CopQuestion.questions_for(@organization).include?(CopQuestion.find_by_position(3))
    end
  end

  private
    def init_data(signatory=false)
      create_organization_and_user
      create_initiative
      create_signing(:organization_id => @organization.id,
                     :initiative_id   => Initiative.first.id) if signatory
      # create a few questions
      create_principle_area
      create_cop_question :position => 1
      create_cop_question :position => 2
      create_cop_question :position => 3, :initiative_id => Initiative.first.id
    end
end
