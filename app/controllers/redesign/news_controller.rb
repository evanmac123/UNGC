class Redesign::NewsController < Redesign::ApplicationController
  def index
    set_current_container :news, '/news'
    @page = NewsPage.new(current_container, current_payload_data)
  end

  def show
  end

  def press_releases
    set_current_container :pr_list, '/press-releases'
    @page = NewsListPage.new(current_container, current_payload_data, page: params[:page])
  end
end
