class Redesign::Admin::Api::ContainersController < Redesign::Admin::ApiController
  def create
    return unless data = validate_layout_data!

    container = Redesign::Container.create(
      slug:   container_params[:slug] || '/',
      layout: container_params[:layout],
      data:   data
    )

    if container.valid?
      render_json data: serialize(container), status: 200
    else
      render_container_errors(container)
    end
  end

  def update
    return unless data = validate_layout_data!

    container = Redesign::Container.find(params[:id])

    if container.update(data: data)
      render text: '', status: 204
    else
      render_container_errors(container)
    end
  end

  def publish
    container = Redesign::Container.
      includes(:draft_payload, :public_payload).
      find(params[:id])

    if ContainerPublisher.new(container).publish
      render text: '', status: 204
    else
      render_errors [{
        code: 'invalid',
        detail: 'container needs a draft payload in order to be published'
      }], status: 400
    end
  end

  def show
    container = Redesign::Container.find(params[:id])
    render_json data: serialize(container)
  end

  def index
    scope = Redesign::Container.order(:layout, :slug)

    containers = if (val = (params[:depth] || params[:depths]))
      scope.where(depth: val.split(',').map(&:to_i))
    elsif (val = (params[:parent_container] || params[:parent_containers]))
      scope.where(parent_container_id: val.split(',').map(&:to_i))
    else
      scope
    end

    render_json data: containers.load.map(&method(:serialize))
  end

  private

  def serialize(container)
    ContainerSerializer.new(container).as_json
  end

  def render_container_errors(container)
    errors = []

    container.errors.each do |field, messages|
      messages.each do |msg|
        errors << { type: 'invalid', path: field, detail: msg }
      end
    end

    render_errors(errors, status: 422)
  end

  def validate_layout_data!
    if Redesign::Container.layouts[container_params[:layout]]
      layout_class = "#{container_params[:layout]}_layout".classify.constantize
    else
      render_errors [{
        path: 'layout',
        detail: 'layout is unknown'
      }], status: 404

      return false
    end

    layout = layout_class.new(container_params[:data])

    if layout.valid?
      layout.as_json
    else
      render_errors layout.errors.map { |error|
        error[:path] = "data.#{error[:path]}"
        error
      }, status: 422

      return false
    end
  end

  def container_params
    params.require(:data).permit!
  end
end
