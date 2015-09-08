class AllOurWorkController < ApplicationController

  def index
    set_current_container_by_path '/what-is-gc/our-work/all'
    @search = AllOurWorkForm.new(search_params, seed)
    @page = AllOurWorkPage.new(current_container, current_payload_data, @search.execute)
  end

  private

  def search_params
    params.fetch(:search, {})
      .permit(
        issues: [],
        topics: [],
        sustainable_development_goals: []
      )
      .merge(page: page)
  end

  def page
    params.fetch(:page, 1).try(:to_i)
  end

  def seed
    if !params[:page]
      session[:random_seed_all_our_work] = rand(100)
    else
      session[:random_seed_all_our_work] ||= rand(100)
    end
  end

end
