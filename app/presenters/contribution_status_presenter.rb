class ContributionStatusPresenter
  def initialize(organization)
    @contributionStatus = ContributionStatus.new(organization)
  end

  def contribution_years
    @contributionStatus.contribution_years
  end
end
