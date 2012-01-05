class AssignYearToCopQuestionGroupsAndRemoveTemporaryGroupings < ActiveRecord::Migration
  def self.up
    # first assign year to previous additional questions
    CopQuestion.update_all({:year => 2011}, ['grouping = ?', "additional"])

    # assign year to previous questions sets
    CopQuestion.update_all({:year => 2011}, ['grouping IN (?)', ['strategy', 'un_goals', 'value_chain', 'verification', 'governance']])

    # then change temporary grouping for 2012 to additional
    CopQuestion.update_all({:year => 2012, :grouping => 'additional'}, ["grouping = 'additional_2012'"])
    CopQuestion.update_all({:year => 2012, :grouping => 'un_goals'}, ["grouping = 'un_goals_2012'"])
    CopQuestion.update_all({:year => 2012, :grouping => 'strategy'}, ["grouping = 'strategy_2012'"])
    CopQuestion.update_all({:year => 2012, :grouping => 'value_chain'}, ["grouping = 'value_chain_2012'"])
    CopQuestion.update_all({:year => 2012, :grouping => 'verification'}, ["grouping = 'verification_2012'"])
    CopQuestion.update_all({:year => 2012, :grouping => 'governance'}, ["grouping = 'governance_2012'"])

    CopQuestion.update_all({:year => 2012}, ['grouping = ?', "lead_un_goals"])
    CopQuestion.update_all({:year => 2012}, ['grouping = ?', "lead_gc"])

    CopQuestion.update_all({:year => 2010}, ['grouping IN (?)', ['mandatory','notable']])
    CopQuestion.update_all({:year => 2010, :grouping => 'additional'}, ['grouping = ?', "additional_disabled"])
    
  end

  def self.down
    CopQuestion.update_all({:grouping => 'additional_2012'}, ["grouping = 'additional' AND year = 2012"])
    CopQuestion.update_all({:grouping => 'un_goals_2012'}, ["grouping = 'un_goals' AND year = 2012"])
    CopQuestion.update_all({:grouping => 'strategy_2012'}, ["grouping = 'strategy' AND year = 2012"])
    CopQuestion.update_all({:grouping => 'value_chain_2012'}, ["grouping = 'value_chain'AND year = 2012"])
    CopQuestion.update_all({:grouping => 'verification_2012'}, ["grouping = 'verification' AND year = 2012"])
    CopQuestion.update_all({:grouping => 'governance_2012'}, ["grouping = 'governance' AND year = 2012"])
    CopQuestion.update_all({:grouping => 'additional_disabled'}, ["grouping = 'additional' AND year = 2010"])
    CopQuestion.update_all(:year => nil)
  end
end
