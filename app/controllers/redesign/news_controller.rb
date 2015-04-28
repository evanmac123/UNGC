class Redesign::NewsController < Redesign::ApplicationController
  def index
    set_current_container :news, '/news'
    @page = NewsPage.new(current_container, current_payload_data)
  end

  def show
    find_headline
    @page = OpenStruct.new({
      hero: {title: {title1: 'News'}, size: 'small', show_section_nav: false},
      meta_title: @headline.title,
      meta_description: nil,
      meta_keywords: nil
    })
  end

  def press_releases
    set_current_container :pr_list, '/press-releases'
    @page = NewsListPage.new(current_container, current_payload_data, page: params[:page])
  end

  private
    def find_headline
      id = headline_id_from_permalink
      @headline = Headline.published.find_by_id(id)
    end

    def headline_id_from_permalink
      # to_i will convert the leading id portion to an int
      # or the whole thing it's just the id
      params.fetch(:id).to_i
    end
end
