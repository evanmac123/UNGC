class Redesign::NewsListForm
  attr_reader \
    :page,
    :per_page

  def initialize(page = 1, params = {})
    @per_page = 5
    @page = page
  end

  def results
    # TODO use a sphinx index instead and mimic library_search_form?
    Headline.order('published_on desc').paginate(page: page, per_page: per_page)
  end
end
