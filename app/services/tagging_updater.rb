class TaggingUpdater
  attr_reader :object, :taggings

  def initialize(taggings={}, object)
    @taggings = taggings
    @object = object
  end

  def submit
    topic_taggings
    issue_taggings
    sector_taggings

    true
  end

  private

  def topic_taggings
    topic_ids = taggings.fetch(:topics, [])
    object.taggings.where('topic_id not in (?)', topic_ids).destroy_all
    topic_ids.each do |id|
      object.taggings.where(topic_id: id).first_or_create!
    end
  end

  def issue_taggings
    ids = taggings.fetch(:issues, [])
    object.taggings.where('issue_id not in (?)', ids).destroy_all
    ids.each do |id|
      object.taggings.where(issue_id: id).first_or_create!
    end
  end

  def sector_taggings
    ids = taggings.fetch(:sectors, [])
    object.taggings.where('sector_id not in (?)', ids).destroy_all
    ids.each do |id|
      object.taggings.where(sector_id: id).first_or_create!
    end
  end
end
