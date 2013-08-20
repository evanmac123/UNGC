class ResourceForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def initialize(resource=nil)
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

  def resource
    @resource ||= Resource.new
  end

  def validate_links
    resource.links.map do |link|
      if link.valid?
        true
      else
        link.errors.each do |k,v|
          errors.add "link_#{k}", v
        end
        false
      end
    end.all?
  end

  def submit(params)
    resource.attributes = params.slice(:title, :description, :year, :isbn, :image_url, :principle_ids, :author_ids)

    if params[:links]
      new_links = params[:links].map do |link|
        l = resource.links.find_or_initialize_by_id(link[:id])
        l.attributes = link.slice(:title, :url, :link_type, :language_id)
        l
      end
    end

    if valid?

      if params[:links]
        current_link_ids = params[:links].map { |l| l[:id].to_i }
        resource.links.where('id NOT IN (?)', current_link_ids).destroy_all
      end

      resource.save!

      if params[:links]
        new_links.map &:save
      end

      true
    else
      false
    end
  end

end
