class BasicCopForm < CopForm

  METHODS = {
    :gc_website   => "a) On the UN Global Compact website only",
    :all_access   => "b) COP will be made easily accessible to all interested parties on company website",
    :stakeholders => "c) COP is actively distributed to all key stakeholders (e.g. investors, employers, consumers, local community)",
    :all          => "d) Both b) and c)"
  }.freeze

  def filters
    PrincipleArea::FILTERS
  end

  def methods
    METHODS
  end

  def areas(key)
    Principle.principles_for_issue_area(key)
  end

  def cop_file
    nil # basic cop forms don't have a cop_file.
  end

  def valid?
    cop.valid?
  end

  def errors
    cop.errors
  end

end