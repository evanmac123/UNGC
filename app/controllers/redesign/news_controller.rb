class Redesign::NewsController < Redesign::ApplicationController
  def index
    set_current_container :news, '/news'
    @page = NewsPage.new(current_container, current_payload_data)
  end

  def show
  end

  def all
    @page = FakeNewsListPage.new
  end
end
