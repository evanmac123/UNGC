class ExpressCopForm

  def initialize(cop, type, contact_info)
    @cop = cop
    @type = type
  end

  def build_cop_answers
    # no-op
  end

  def title
    @cop.title
  end

  def cop_type
    @type
  end

  def endorses_ten_principles
    @cop.endorses_ten_principles
  end

  def covers_issue_areas
    @cop.covers_issue_areas
  end

  def measures_outcomes
    @cop.measures_outcomes
  end
end

