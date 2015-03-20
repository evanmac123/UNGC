class NewsController < ApplicationController
  helper :pages
  before_filter :find_headline, :only => :show
  before_filter :determine_navigation # find_headline needs to go first!

  def index
    if params[:year]
      @year = params[:year].try(:to_i) || Date.today.year
      @headlines = Headline.for_year(@year)
    else
      @headlines = Headline.published.order("published_on DESC").limit(9).all
    end
  end

  def show
  end

  private
    def find_headline
      id = headline_id_from_permalink
      @headline = Headline.published.find_by_id(id)
      if @headline.nil?
        redirect_back_or_to('/')
      elsif not_using_permalink_url
        redirect_to headline_url(@headline)
      end
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

    def not_using_permalink_url
      @headline.to_param != params[:permalink]
    end

    def headline_id_from_permalink
      # to_i will convert the leading id portion to an int
      # or the whole thing it's just the id
      params.fetch(:permalink).to_i
    end

    def year
      @year
    end
    helper_method :year
end
