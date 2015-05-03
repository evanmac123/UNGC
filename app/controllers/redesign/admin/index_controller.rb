class Redesign::Admin::IndexController < Redesign::Admin::AdminController
  def frontend
    index_key = ''
    if Rails.env.development?
      index_key = 'admin:__development__'
    else
      index_key = $redis.get('admin:current')
    end
    render text: $redis.get(index_key), layout: false
  end
end
