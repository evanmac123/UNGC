require 'test_helper'

class PrincipleTest < ActiveSupport::TestCase
  should_validate_presence_of :name
  should_have_and_belong_to_many :communication_on_progresses

  context "given a principle area" do
    setup do
      create_principle_areas
      labour = PrincipleArea.area_for(PrincipleArea::FILTERS[:labour])
      human_rights = PrincipleArea.area_for(PrincipleArea::FILTERS[:human_rights])
      environment = PrincipleArea.area_for(PrincipleArea::FILTERS[:environment])
      anti_corruption = PrincipleArea.area_for(PrincipleArea::FILTERS[:anti_corruption])

      create_principle(:name => "Principle 1: Human Rights", :parent_id => human_rights.id)
      create_principle(:name => "Principle 2: Human Rights", :parent_id => human_rights.id)
      create_principle(:name => "Principle 3: Labour", :parent_id => labour.id)
      create_principle(:name => "Principle 4: Labour", :parent_id => labour.id)
      create_principle(:name => "Principle 5: Labour", :parent_id => labour.id)
      create_principle(:name => "Principle 6: Labour", :parent_id => labour.id)
      create_principle(:name => "Principle 7: Environment", :parent_id => environment.id)
      create_principle(:name => "Principle 8: Environment", :parent_id => environment.id)
      create_principle(:name => "Principle 9: Environment", :parent_id => environment.id)
      create_principle(:name => "Principle 10: Anti-Corruption", :parent_id => anti_corruption.id)
    end

    should "find the principles for a given principle area" do
      @human_rights_principles = Principle.principles_for_issue_area(:human_rights)
      assert_equal 2, @human_rights_principles.count
      @labour_principles = Principle.principles_for_issue_area(:labour)
      assert_equal 4, @labour_principles.count
      @env_principles = Principle.principles_for_issue_area(:environment)
      assert_equal 3, @env_principles.count
      @ac_principles = Principle.principles_for_issue_area(:anti_corruption)
      assert_equal 1, @ac_principles.count
    end
  end

end
