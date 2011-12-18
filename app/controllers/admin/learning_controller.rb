class Admin::LearningController < AdminController
  def index
    render :template => '/search/offline' unless ThinkingSphinx.sphinx_running?
    @search = LocalNetworkEventSearch.new params[:local_network_event_search]
  end

  def search
    @search = LocalNetworkEventSearch.new params[:local_network_event_search]
    @search.page = params[:page] || 1
    @search.per_page = 10
  end
end

