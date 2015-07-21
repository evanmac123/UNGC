class Sitemap::IndexController < Sitemap::AdminController
  SHORT_UUID_V4_REGEXP = /\A[0-9a-f]{7}\z/i
  def frontend
    index_key = if Rails.env.development?
                  'sitemap:__development__'
                elsif fetch_revision
                  "sitemap:#{fetch_revision}"
                else
                  UNGC::Redis.with_connection { |r| r.get('sitemap:current') }
                end
    index = UNGC::Redis.with_connection { |r| r.get(index_key) }
    render text: add_token_to_index(index), layout: false
  end

  private

  def fetch_revision
    rev = params[:revision]
    if rev =~ SHORT_UUID_V4_REGEXP
      rev
    end
  end

  def add_token_to_index(index)
    token = form_authenticity_token
    index.sub(/CSRF_TOKEN/, token)
  end

end
