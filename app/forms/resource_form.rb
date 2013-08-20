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

  def submit(params)
    resource.attributes = params.slice(:title, :description, :year, :isbn, :image_url, :principle_ids, :author_ids)
    resource.link
    if valid?
      resource.save!
      persist_links(params[:links])
    else
      false
    end
  end

  private

  def persist_links(links=[])
    # remove old links
    current_link_ids = links.map { |l| l[:id].to_i }
    resource.links.where('id NOT IN (?)', current_link_ids).destroy_all

    # create new links and update existing ones
    links.all? do |link|
      l = resource.links.find_or_initialize_by_id(link[:id])
      unless l.update_attributes(link.slice(:title, :url, :link_type, :language_id))
        l.errors.each do |k,v|
          errors.add "link_#{k}", v
        end
      end
      l.valid?
    end
  end

end