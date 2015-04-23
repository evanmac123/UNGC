class HeadlineUpdater
  attr_reader :headline, :params

  def initialize(params={}, headline=Headline.new, tagging_updater=TaggingUpdater)
    @headline = headline
    @params = params
    @taggings = params.slice(:issues,:topics,:sectors)
    @tagging_updater = tagging_updater
  end

  def submit
    headline.title          = params[:title]
    headline.description    = params[:description]
    headline.location       = params[:location]
    headline.country_id     = params[:country_id]
    headline.published_on   = params[:published_on]
    headline.headline_type  = params[:headline_type]

    if valid?
      headline.save!

      updater = @tagging_updater.new(@taggings, headline)
      updater.update

      true
    else
      false
    end
  end

  private

  def valid?
    headline.valid?
    headline.errors.empty?
  end
end
