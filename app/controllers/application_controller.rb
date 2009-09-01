# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_url
    url_for :only_path => true
  end
  helper_method :current_url

  def look_for_path
    unless @look_for_path
      @look_for_path = "/#{params[:path].join('/')}"
      @look_for_path << '/index.html' unless @look_for_path =~ /\.html$/
    end
    @look_for_path
  end
  helper_method :look_for_path
end
