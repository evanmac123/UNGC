class Sitemap::ApiController < Sitemap::AdminController
  protect_from_forgery with: :null_session

  protected

  def render_json(json, opts = {})
    render({
      json: json,
      serializer: nil
    }.merge(opts))
  end

  def render_errors(errors, opts = {})
    render_json({ errors: errors }, opts)
  end
end
