class NewsController < ApplicationController
  helper :pages
  before_filter :find_headline, :only => :show
  before_filter :determine_navigation # find_headline needs to go first!

  def index
    if params[:year]
      @year = params[:year].try(:to_i) || Date.today.year
      @headlines = Headline.for_year(@year)
    else
      @headlines = Headline.published.find(:all, :order => "published_on DESC", :limit => 9)
    end
  end

  def feed
    @headlines = Headline.find(:all, :order => "published_on DESC", :limit => 9)
    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

  def show
  end

  private
    def find_headline
      @headline = Headline.published.find_by_id(params[:permalink].to_i)
      redirect_back_or_to and return unless @headline
      redirect_to(:permalink => @headline.to_param) unless @headline.to_param == params[:permalink]
    end

    def default_navigation
      if show_archive?
        DEFAULTS[:news_archive_path]
      else
        DEFAULTS[:news_headlines_path]
      end
    end
    
    def show_archive?
      return true if action_name == 'index'
      @headline.published_on < (Date.today << 1) # older than one month
    end
    
    def year
      @year
    end
    helper_method :year
end
