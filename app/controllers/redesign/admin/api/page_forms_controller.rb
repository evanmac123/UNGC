class Redesign::Admin::Api::PageFormsController < Redesign::Admin::ApiController
  FORMS = {
    home_page:  HomePageForm,
    about_page: AboutPageForm
  }

  def index
    render_json data: FORMS.values.map(&method(:serialize))
  end

  def show
    if (found = lookup_form(params[:id]))
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

  def lookup_form(key)
    FORMS[key.to_sym]
  end

  def serialize(page_form)
    { id:                  page_form.kind,
      type:                :page_form,
      label:               page_form.label,
      has_many_containers: page_form.has_many_containers?,
      containers_count:    page_form.containers_count }
  end
end
