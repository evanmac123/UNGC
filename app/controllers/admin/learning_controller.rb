class Admin::LearningController < AdminController
  def index
    @search = LocalNetworkEventSearch.new params[:local_network_event_search]
  end

  def search
    @search = LocalNetworkEventSearch.new params[:local_network_event_search]
    @search.page = params[:page] || 1
    @search.per_page = 10
  end
end

