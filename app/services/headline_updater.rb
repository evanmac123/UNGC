class HeadlineUpdater
  attr_reader :headline, :params

  def initialize(params={}, headline=Headline.new)
    @headline = headline
    @params = params
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

      topic_taggings
      issue_taggings
      sector_taggings

      true
    else
      false
    end
  end

  private

  def topic_taggings
    topic_ids = params.fetch(:topics, [])
    headline.taggings.where('topic_id not in (?)', topic_ids).destroy_all
    topic_ids.each do |id|
      headline.taggings.where(topic_id: id).first_or_create!
    end
  end

  def issue_taggings
    ids = params.fetch(:issues, [])
    headline.taggings.where('issue_id not in (?)', ids).destroy_all
    ids.each do |id|
      headline.taggings.where(issue_id: id).first_or_create!
    end
  end

  def sector_taggings
    ids = params.fetch(:sectors, [])
    headline.taggings.where('sector_id not in (?)', ids).destroy_all
    ids.each do |id|
      headline.taggings.where(sector_id: id).first_or_create!
    end
  end

  def valid?
    headline.valid?
    headline.errors.empty?
  end
end
