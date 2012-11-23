class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  before_filter :mailer_set_url_options

  helper 'datetime', 'navigation'
  protect_from_forgery

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_url
    url_for :only_path => true
  end
  helper_method :current_url

  def home_page?
    current_url == root_path || formatted_request_path == "/index.html"
  end
  helper_method :home_page?

  def formatted_request_path
    unless @formatted_request_path
      if params[:path]
        @formatted_request_path = "/#{params[:path]}"
        @formatted_request_path << '/index.html' unless @formatted_request_path =~ /\.html$/
      end
      @formatted_request_path = @formatted_request_path.gsub('//', '/') if @formatted_request_path.respond_to?(:gsub)
    end
    @formatted_request_path
  end
  helper_method :formatted_request_path

  def staff_user?
    logged_in? && current_user.from_ungc?
  end
  helper_method :staff_user?

  def editable_content?
    @is_editable_content
  end
  helper_method :editable_content?


  protected

  def rescue_action(exception)
    case exception
    when Riddle::ConnectionError
      render :template => '/search/offline' and return false
    else
      super
    end
  end

  def mailer_set_url_options
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end

  # For Rails actions that we want to "appear" as if they were part of the navigation tree
  def determine_navigation
    @formatted_request_path = default_navigation and return if params[:navigation].blank?
    @formatted_request_path = case params[:navigation]
    when 'inactive'
      DEFAULTS[:cop_inactives_path]
    when 'noncommunicating'
      DEFAULTS[:cop_noncommunicating_path]
    when 'notable'
      DEFAULTS[:cop_notable_path]
    when 'advanced'
      DEFAULTS[:cop_advanced_path]
    when 'learner'
      DEFAULTS[:cop_learner_path]
    when 'expelled'
      DEFAULTS[:cop_expelled_path]
    when 'lead'
      DEFAULTS[:participant_lead_path]
    else
      default_navigation
    end
  end

  def default_navigation # override in other controllers
    DEFAULTS[:participant_search_path]
  end

  def page_is_editable
    @is_editable_content = true
  end

  def redirect_back_or_to(options='/')
    if request.env["HTTP_REFERER"]
      redirect_to :back
    else
      redirect_to options
    end
  end
end
