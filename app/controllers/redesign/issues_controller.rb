class Redesign::IssuesController < Redesign::ApplicationController
  def index
    set_current_container :all_issue, '/what-is-un-global-compact/our-focus/all-issues'
    @page = AllIssuePage.new(current_container, current_payload_data)
  end
end
