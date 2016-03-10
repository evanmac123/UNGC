class SdgPioneerOtherReport < SimpleReport

  def records
    SdgPioneer::Other.all
  end

  def header
    []
  end

  def row(business)
    []
  end

end
