class ResourcesController < ApplicationController

  def search
    unless params[:keyword].blank?
      results_for_search
    else
      show_search_form
    end
  end

  private

    def results_for_search
      # TODO get results
      render :action => 'index'
    end

    def show_search_form
      render :action => 'search_form'
    end

end
