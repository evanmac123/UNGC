class Redesign::Admin::IndexController < Redesign::Admin::AdminController
  def frontend
    index_key = if Rails.env.development?
                  'admin:__development__'
                elsif params[:revision]
                  "admin:#{params[:revision]}"
                else
                  $redis.get('admin:current')
                end
    index = $redis.get(index_key)
    render text: add_token_to_index(index), layout: false
  end

  private

  def add_token_to_index(index)
    html = render_to_string(text: '', layout: 'redesign/admin')
    token = extract_token(html)
    index.sub(/CSRF_TOKEN/, token)
  end

  def extract_token(html)
    html.match(/<meta name="csrf-token" content="(.*)" \/>/)[1]
  end
end
