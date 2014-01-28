class NonBusinessCopForm < CopForm

  METHODS = {
    :gc_website   => "a) Through the UN Global Compact website only",
    :all_access   => "b) COE is easily accessible to all interested parties (e.g. via its website)",
    :stakeholders => "c) COE is actively distributed to all key stakeholders (e.g. investors, employees, beneficiaries, local community)",
    :all          => "d) Both b) and c)"
  }.freeze

  def formats
    CoePresenter::FORMATS
  end

  def methods
    METHODS
  end

end