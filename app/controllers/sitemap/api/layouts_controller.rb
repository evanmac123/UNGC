class Sitemap::Api::LayoutsController < Sitemap::ApiController
  LAYOUTS = {
    academy: AcademyLayout,
    article:   ArticleLayout,
    highlight: HighlightLayout,
    landing:   LandingLayout,
    action_detail: ActionDetailLayout,
    issue: IssueLayout,
    list: ListLayout,
    accordion: AccordionLayout,
  }

  def index
    render_json data: LAYOUTS.values.map(&method(:serialize))
  end

  def show
    if (found = lookup_layout(params[:id]))
      render_json data: serialize(found)
    else
      render_json({
        errors: [
          { code: 'not_found' }
        ]
      }, status: 404)
    end
  end

  private

  def lookup_layout(key)
    LAYOUTS[key.to_sym]
  end

  def serialize(layout)
    { id:                  layout.layout,
      type:                'layout',
      label:               layout.label,
      has_many_containers: layout.has_many_containers?,
      containers_count:    layout.containers_count }
  end
end
