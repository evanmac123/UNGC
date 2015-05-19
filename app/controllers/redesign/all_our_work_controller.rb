class Redesign::AllOurWorkController < Redesign::ApplicationController

  def index
    set_current_container :all_issue, '/what-is-un-global-compact/our-focus/all-issues'
    @search = Redesign::AllOurWorkForm.new(search_params)
    @page = AllOurWorkPage.new(current_container, current_payload_data, @search.execute)
  end

  private

  def search_params
    params.fetch(:search, {})
      .permit(issues: [], topics: [])
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1)
  end

end
