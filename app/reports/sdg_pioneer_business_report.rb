class SdgPioneerBusinessReport < SimpleReport

  def records
    SdgPioneer::Business.all
  end

  def header
    []
  end

  def row(business)
    []
  end

end
