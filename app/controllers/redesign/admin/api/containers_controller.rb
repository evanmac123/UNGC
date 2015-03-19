class Redesign::Admin::Api::ContainersController < Redesign::Admin::ApiController
  def create
    layout = HomeLayout.new(data_params[:data])

    if layout.valid?
      data = layout.as_json
    else
      render_errors layout.errors, status: 422
      return
    end

    container = Redesign::Container.create(
      slug:   data_params[:slug] || '/',
      layout: data_params[:layout],
      initial_payload_data: data
    )

    if container.valid?
      render_json serialize(container), status: 202
    else
      errors = []

      container.errors.each do |field, messages|
        messages.each do |msg|
          errors << { type: 'invalid', path: 'field', detail: msg }
        end
      end

      render_errors(errors, status: 422)
    end
  end

  def show
    container = Redesign::Container.find(params[:id])
    render json: serialize(container)
  end

  private

  def serialize(container)
    ContainerSerializer.new(container).as_json
  end

  def data_params
    params.require(:data).permit!
  end
end
