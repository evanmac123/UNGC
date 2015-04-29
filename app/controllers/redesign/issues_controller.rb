class Redesign::IssuesController < Redesign::ApplicationController
  def index
    set_current_container :all_issue, '/what-is-un-global-compact/our-focus/all-issues'
    form= Redesign::AllOurWorkForm.new(params[:page])
    @page = AllOurWorkPage.new(current_container, current_payload_data, form.results)
  end
end
