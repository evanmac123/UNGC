class Redesign::LibraryController < Redesign::ApplicationController
  layout 'redesign/application'

  def index
    set_current_container :library, '/explore-our-library'
    @search = Redesign::LibrarySearchForm.new
    @page = ExploreOurLibraryPage.new(current_container, current_payload_data)
    @results = []
  end

  def show
    @resource = Presenter.new(Resource.find(params[:id]))
  end

  def search
    @search = Redesign::LibrarySearchForm.new(params[:page], search_params)
    @results = Resource.search @search.keywords, @search.options
  end

  private

  def search_params
    params[:search]
  end

  class Presenter < SimpleDelegator

    def placeholder_data
      'place fake data here if you want.'
    end

    def video?
      videos.any?
    end

    def videos
      @videos ||= self.links.videos.map do |v|
        YoutubeVideoPresenter.new(v)
      end
    end

  end

  class YoutubeVideoPresenter
    def initialize(video)
      @video = video
    end

    def id
      url = CGI::parse(@video.url)
      url['v'].first
    end

    def embed_url
      "https://www.youtube.com/embed/#{id}"
    end
  end

end
