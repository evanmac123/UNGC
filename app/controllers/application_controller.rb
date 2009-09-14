# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  USERNAME = 'ungc'
  PASSWORD = 'unspace123'
  
  before_filter :simple_http_auth
  before_filter :mailer_set_url_options

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_url
    url_for :only_path => true
  end
  helper_method :current_url
  
  def home_page?
    current_url == root_path
  end
  helper_method :home_page?

  def look_for_path
    unless @look_for_path
      @look_for_path = "/#{params[:path].join('/')}" if params[:path]
      @look_for_path << '/index.html' if @look_for_path unless @look_for_path =~ /\.html$/
    end
    @look_for_path
  end
  helper_method :look_for_path

  protected
    def simple_http_auth
      if RAILS_ENV == 'production'
        authenticate_or_request_with_http_basic do |username, password|
          username == USERNAME && password == PASSWORD
        end
      end
    end
    
    def mailer_set_url_options
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end
end
