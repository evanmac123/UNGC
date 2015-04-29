class Redesign::IssuesController < Redesign::ApplicationController
  def index
    set_current_container :all_issue, '/what-is-un-global-compact/our-focus/all-issues'
    results = Redesign::Container.issue.includes(:public_payload)
    @page = AllIssuePage.new(current_container, current_payload_data, results)
  end
end
