class Redesign::LibraryController < Redesign::ApplicationController

  def index
    set_current_container :library, '/library'
    @search = Redesign::LibrarySearchForm.new
    @page = create_page
    @results = []
  end

  def show
    @resource = Presenter.new(Resource.find(params[:id]))
  end

  def search
    @search = Redesign::LibrarySearchForm.new(page, search_params)
    @page = create_page
    @results = @search.execute
  end

  private

  def search_params
    params.fetch(:search, {}).permit(
      :keywords,
      :content_type,
      :sort_field,
      issue_areas: [],
      issues: [],
      topic_groups: [],
      topics: [],
      languages: [],
      sector_groups: [],
      sectors: []
    )
  end

  def page
    params.fetch(:page, 1)
  end

  def create_page
    ExploreOurLibraryPage.new(current_container, current_payload_data)
  end

  class Presenter < SimpleDelegator

    def placeholder_data
      'place fake data here if you want.'
    end

    def links_list
      self.links.map do |l|
        LinkPresenter.new(l)
      end
    end

  end

  class LinkPresenter

    def initialize(link)
      @link = link
    end

    def title
      @link.title
    end

    def type
      @link.link_type
    end

    def url
      @link.url
    end

    def language
      @link.language.name
    end

    def is_video?
      type == 'video'
    end

    def is_youtube?
      if is_video?
        host = URI.parse(url).host
        return host == 'www.youtube.com'
      end
      false
    end

    def video_id
      if is_youtube?
        q = URI.parse(@link.url).query
        return CGI::parse(q)['v'].first if q
      end
      nil
    end

    def embed_url
      if is_youtube?
        "https://www.youtube.com/embed/#{video_id}"
      else
        ''
      end
    end

  end

end
