class SdgPioneerIndividualReport < SimpleReport

  def records
    SdgPioneer::Individual.all
  end

  def header
    []
  end

  def row(business)
    []
  end

end
