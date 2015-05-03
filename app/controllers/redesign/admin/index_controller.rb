class Redesign::Admin::IndexController < Redesign::Admin::AdminController
  def frontend
    index_key = if Rails.env.development?
                  'admin:__development__'
                elsif params[:revision]
                  "admin:#{params[:revision]}"
                else
                  $redis.get('admin:current')
                end
    render text: $redis.get(index_key), layout: false
  end
end
