class Redesign::ActionsController < Redesign::ApplicationController
  def index
    set_current_container_by_path '/take-action/action'
    @search = Redesign::WhatYouCanDoForm.new(search_params, seed)
    @page = ActionPage.new(current_container, current_payload_data, @search.execute)
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
      session[:random_seed_action] = rand(100)
    else
      session[:random_seed_action]
    end
  end

end
