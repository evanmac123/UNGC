class ResourceUpdater
  attr_reader :resource, :params

  def initialize(params={}, resource=Resource.new, tagging_updater=TaggingUpdater)
    @resource = resource
    @params = params
    @taggings = params.slice(:issues,:topics,:sectors)
    @tagging_updater = tagging_updater
  end

  def submit
    resource.attributes = params.slice(:title, :description, :isbn, :principle_ids, :author_ids, :image, :content_type)
    resource.year = year if has_year?

    if valid?
      remove_old_links
      resource.save!
      updated_links.map(&:save!)

      updater = @tagging_updater.new(@taggings, resource)
      updater.submit

      true
    else
      false
    end
  end

  private

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
