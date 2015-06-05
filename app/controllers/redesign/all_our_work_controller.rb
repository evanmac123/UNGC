class Redesign::AllOurWorkController < Redesign::ApplicationController

  def index
    set_current_container_by_path '/what-is-gc/our-work/all'
    @search = Redesign::AllOurWorkForm.new(search_params, seed)
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

  def seed
    if !params[:page]
      r = rand(100)
      session[:random_seed] = r
    else
      session[:random_seed]
    end
  end

end
