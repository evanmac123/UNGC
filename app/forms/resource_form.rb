class ResourceForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :resource, :params

  def initialize(resource=Resource.new)
    @resource = resource
  end

  def persisted?
    false
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Resource")
  end

  validates_presence_of :title, :description
  validate :validate_links
  # TODO validate year format
  # TODO validate image_url format
  # TODO validate isbn format?

  delegate :title,
           :description,
           :year,
           :isbn,
           :image_url,
           :principle_ids,
           :authors,
           :authors_ids,
           :links,
           to: :resource

  def submit(params={})
    @params = params
    resource.attributes = @params.slice(:title, :description, :year, :isbn, :image_url, :principle_ids, :author_ids)

    if valid?
      remove_old_links
      resource.save!
      updated_links.map(&:save!)
      true
    else
      false
    end
  end

  private

  def validate_links
    updated_links.map do |link|
      if link.valid?
        true
      else
        link.errors.each do |field, message|
          errors.add "link_#{field}", message
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
      l = resource.links.find_or_initialize_by_id(link[:id])
      l.attributes = link.slice(:title, :url, :link_type, :language_id)
      l
    end
  end

end
