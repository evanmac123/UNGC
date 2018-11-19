class NewsController < ApplicationController
  def index
    set_current_container_by_path '/news'
    @page = NewsPage.new(current_container, current_payload_data)
  end

  def show
    set_current_container_by_path '/news/press-releases'
    @page = NewsShowPage.new(current_container, find_headline)
  end

  def press_releases
    set_current_container_by_path '/news/press-releases'
    @search = NewsListForm.new(search_params)
    @page = NewsListPage.new(current_container, current_payload_data, @search.execute)
  end

  private
    def find_headline
      Headline.published.includes(:country).find(params.fetch(:id))
    end

    def search_params
      search_params = params[:search] || ActionController::Parameters.new({})
      search_params.permit(
        :start_date,
        :end_date,
        issues: [],
        topics: [],
        countries: [],
        types: [],
        sustainable_development_goals: []
      ).merge(page: page)
    end

    def page
      params.fetch(:page, 1).try(:to_i)
    end
end
