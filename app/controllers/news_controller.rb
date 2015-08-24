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
      id = headline_id_from_permalink
      Headline.published.includes(:country).find(id)
    end

    def headline_id_from_permalink
      # to_i will convert the leading id portion to an int
      # or the whole thing it's just the id
      params.fetch(:id).to_i
    end

    def search_params
      params.fetch(:search, {}).permit(
        :start_date,
        :end_date,
        issues: [],
        topics: [],
        countries: [],
        types: []
      ).merge(page: page)
    end

    def page
      params.fetch(:page, 1).try(:to_i)
    end
end
