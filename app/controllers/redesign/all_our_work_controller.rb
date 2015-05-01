class Redesign::AllOurWorkController < Redesign::ApplicationController

  def index
    set_current_container :all_issue, '/what-is-un-global-compact/our-focus/all-issues'
    @search = Redesign::AllOurWorkForm.new(search_params)
    @page = AllOurWorkPage.new(current_container, current_payload_data, @search.execute)
  end

  private

  def search_params
    permitted = params.fetch(:search, {}).permit()
    if page.present?
      permitted.merge(page: page)
    else
      permitted
    end
  end

  def page
    params[:page]
  end

end
