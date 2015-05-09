class Redesign::AllOurWorkForm
  attr_reader \
    :page,
    :per_page

  def initialize(page = 1, params = {})
    @per_page = 12
    @page = page
  end

  def results
    # TODO use a sphinx index instead and mimic library_search_form?
    Redesign::Container.issue.includes(:public_payload).paginate(page: page, per_page: per_page)
  end
end
