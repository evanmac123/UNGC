class Admin::LearningController < AdminController
  def index
    if Search.running?
      @search = LocalNetworkEventSearch.new params[:local_network_event_search]
    else
      render inline: "%h2 The website search index is being updated
%p This allows us to provide you with the latest results. We won't be too long, so please try again in a few minutes.", type: :haml
    end
  end

  def search
    @search = LocalNetworkEventSearch.new params[:local_network_event_search]
    @search.page = params[:page] || 1
    @search.per_page = 10
  end
end
