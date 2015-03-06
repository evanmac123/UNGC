class Redesign::SearchController < ApplicationController
  def index
    @search = SearchForm.new
  end

  def search
    @search = SearchForm.new(search_params)
  end

  private

  def search_params
    # TODO fix the form object so we have a nice param name
    params[:redesign_search_controller_search_form]
  end

end
