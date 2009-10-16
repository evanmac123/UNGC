# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  USERNAME = 'ungc'
  PASSWORD = 'unspace123'
  
  before_filter :simple_http_auth
  before_filter :mailer_set_url_options

  helper 'datetime'
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
      @look_for_path = @look_for_path.gsub('//', '/') if @look_for_path.respond_to?(:gsub)
    end
    @look_for_path
  end
  helper_method :look_for_path
  
  def staff_user?
    logged_in? && current_user.from_ungc?
  end
  helper_method :staff_user?

  def editable_content?
    @is_editable_content
  end
  helper_method :editable_content?

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

    def default_navigation # override in other controllers
      '/COP/cop_search.html'
    end

    def determine_navigation
      logger.info " ** #{params[:navigation]}"
      @look_for_path = case params[:navigation]
      when 'inactive'
        '/COP/inactives.html'
      when 'noncommunicating'
        '/COP/non_communicating.html'
      when 'notable'
        '/COP/notable_cops.html'
      else
        default_navigation
      end
    end

    def page_is_editable
      @is_editable_content = true
    end
end
