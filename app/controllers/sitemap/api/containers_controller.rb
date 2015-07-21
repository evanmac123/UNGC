class Sitemap::Api::ContainersController < Sitemap::ApiController
  before_action :authorize_editor!, only: [:publish]

  def create
    container = Redesign::Container.create(container_create_params)

    if container.valid?
      render_json data: serialize(container), status: 200
    else
      render_container_errors(container)
    end
  end

  def update
    update_params = container_update_params

    if container_params[:data]
      return unless data = validate_layout_data!
      update_params[:data] = data
    end

    container = Redesign::Container.find(params[:id])

    draft = ContainerDraft.new(container, current_contact)

    if draft.save(update_params)
      render_json data: serialize(container), status: 204
    else
      render_container_errors(container)
    end
  end

  def publish
    container = Redesign::Container.
      includes(:draft_payload, :public_payload).
      find(params[:id])

    if ContainerPublisher.new(container, current_contact).publish
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
    scope = Redesign::Container.order(:sort_order, :path)

    containers = if params[:root]
      scope.where(parent_container_id: nil)
    elsif (val = (params[:parent_container] || params[:parent_containers]))
      scope.by_ids_with_descendants(val.split(',').map(&:to_i))
    else
      scope
    end

    render_json data: containers.load.map(&method(:serialize))
  end

  def needs_approval
    containers = Redesign::Container.where(has_draft: true).order(:path)
    render_json data: containers.load.map(&method(:serialize))
  end

  def destroy
    container = Redesign::Container.find(params[:id])
    if !container.draggable
      render text: "This page can not be deleted", status: 422
    elsif container.child_containers.count > 0
      render text: "This page still has children", status: 422
    else
      container.payloads.destroy_all
      container.destroy
      render nothing: true, status: 204
    end
  end

  private

  def serialize(container)
    ContainerSerializer.new(container).as_json
  end

  def render_container_errors(container)
    errors = []

    container.errors.each do |field, messages|
      Array(messages).each do |msg|
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

  def container_create_params
    p = container_params

    {
      layout: p[:layout],
      slug:   p[:slug] || '/',
      path:   p[:public_path],
      parent_container_id: p[:parent_container_id]
    }
  end

  def container_update_params
    h = {}
    p = container_params

    h[:slug] = p[:slug] if p[:slug].present?
    h[:path] = p[:public_path] if p[:public_path].present?
    h[:layout] = p[:layout] if p[:layout].present?
    h[:parent_container_id] = p[:parent_container_id] if p.key?(:parent_container_id)
    h[:data] = p[:data] if p.key?(:data)

    h
  end

  def authorize_editor!
    unless current_contact.is? Role.website_editor
      render text: '', status: 403
    end
  end
end
