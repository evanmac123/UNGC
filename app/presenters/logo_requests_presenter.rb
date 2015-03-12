class LogoRequestsPresenter < SimpleDelegator
  attr_reader :contribution_statuses_by_org

  def initialize(logo_requests, contribution_statuses_by_org)
    super(logo_requests)
    @contribution_statuses_by_org = contribution_statuses_by_org
  end

  def each
    logo_requests.each do |l|
      yield LogoRequestPresenter.new(l, contribution_statuses_by_org[l.organization.id])
    end
  end

  private

  def logo_requests
    __getobj__
  end

end

