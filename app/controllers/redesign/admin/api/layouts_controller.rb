class Redesign::Admin::Api::LayoutsController < Redesign::Admin::ApiController
  LAYOUTS = {
    home:  HomeLayout,
    about: AboutLayout
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
