class ResourceUpdater
  attr_reader :resource, :params

  def initialize(params={}, resource=Resource.new)
    @resource = resource
    @params = params
  end

  def submit
    resource.title          = params[:title]
    resource.description    = params[:description]
    resource.isbn           = params[:isbn]
    resource.content_type   = params[:content_type]
    resource.author_ids     = params[:author_ids]
    resource.image          = params[:imag]
    resource.year           = year if has_year?

    resource.principles.where('id not in (?)', params[:principle_ids]).destroy_all
    Array(params[:principle_ids]).each do |id|
      resource.principles.where(id: id).first_or_create!
    end

    if valid?
      remove_old_links
      resource.save!
      updated_links.map(&:save!)

      topic_taggings
      issue_taggings

      true
    else
      false
    end
  end

  private

  def topic_taggings
    topic_ids = params.fetch(:topics, [])
    resource.taggings.where('topic_id not in (?)', topic_ids).destroy_all
    topic_ids.each do |id|
      resource.taggings.where(topic_id: id).first_or_create!
    end
  end

  def issue_taggings
    ids = params.fetch(:issues, [])
    resource.taggings.where('issue_id not in (?)', ids).destroy_all
    ids.each do |id|
      resource.taggings.where(issue_id: id).first_or_create!
    end
  end

  def valid?
    # we need to call the validations for both
    # the resource and the links in order to populate the error messages
    # and load the links into the resource object if the validation fails
    resource.valid?
    validate_links
    resource.errors.empty?
  end

  def has_year?
    params.has_key?('year(1i)')
  end

  def year
    Time.new(params['year(1i)'].to_i).beginning_of_year
  end

  def validate_links
    updated_links.map do |link|
      if link.valid?
        true
      else
        link.errors.each do |field, message|
          resource.errors.add "link_#{field}", message
        end
        false
      end
    end.all?
  end

  def remove_old_links
    current_ids = updated_links.map { |l| l.id.to_i }
    resource.links.where('id NOT IN (?)', current_ids).destroy_all
  end

  def updated_links
    @updated_links ||= params.fetch(:links, []).map do |link|
      l = resource.links.find_or_initialize_by(id: link[:id])
      l.attributes = link.slice(:title, :url, :link_type, :language_id)
      l
    end
  end

end
