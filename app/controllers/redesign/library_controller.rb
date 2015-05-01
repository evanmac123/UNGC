class Redesign::LibraryController < Redesign::ApplicationController

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
    @search = Redesign::LibrarySearchForm.new(page, search_params)
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
