class Redesign::NewsController < Redesign::ApplicationController
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
    @search = Redesign::NewsListForm.new(search_params)
    @page = NewsListPage.new(current_container, current_payload_data, @search.execute)
  end

  def media
    set_current_container_by_path '/news/media'
    @page = ArticlePage.new(current_container, current_payload_data)
    render 'redesign/static/article'
  end

  def speeches
    set_current_container_by_path '/news/speeches'
    @page = ArticlePage.new(current_container, current_payload_data)
    render 'redesign/static/article'
  end

  def bulletin
    set_current_container_by_path ['/news/bulletin', params[:path]].join('/')
    @page = ArticlePage.new(current_container, current_payload_data)
    render 'redesign/static/article'
  end

  private
    def find_headline
      id = headline_id_from_permalink
      Headline.published.find_by_id(id)
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
        countries: []
      ).merge(page: params[:page])
    end
end
