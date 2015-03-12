class LogoRequestPresenter < SimpleDelegator
  attr_reader :contribution_status

  def initialize(logo_request, contribution_status)
    super(logo_request)
    @contribution_status = contribution_status
  end

  def missing_contribution?
    !@contribution_status.can_submit_logo_request?
  end

  def contribution_status_message
    @contribution_status.can_submit_logo_request? ? 'Contribution received' : "No contribution received for #{current_year} - #{current_year - 1}"
  end

  private

  def current_year
    Date.today.year
  end

end
