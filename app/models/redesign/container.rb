class Redesign::Container < ActiveRecord::Base
  LEADING_OR_TRAILING_SLASH = /\A\/|\/\Z/

  attr_accessor :payload_validator

  enum layout: [
    :home,
    :landing,
    :article,
    :news,
    :tile_grid,
    :highlight,
    :event,
    :event_detail,
    :issue,
    :action_detail,
    :ln_profile,
    :list,
    :pr_list,
    :library,
    :engage_locally,
    :directory,
    :all_issue,
    :accordion
  ]

  enum content_type: [
    :default,
    :action
  ]

  belongs_to :parent_container, class_name: 'Redesign::Container'
  belongs_to :public_payload, class_name: 'Redesign::Payload'
  belongs_to :draft_payload, class_name: 'Redesign::Payload'

  has_many :payloads, class_name: 'Redesign::Payload'

  before_save :schedule_notify_previous_parent_of_child_association_change

  after_save :update_draft_payload
  after_save :recache_parent_container_child_containers_count
  after_save :notify_previous_parent_of_child_association_change

  after_destroy :reassociate_child_containers_to_next_parent
  after_destroy :recache_parent_container_child_containers_count

  validate :validate_draft_payload
  validates :path, uniqueness: true
  validates :slug, uniqueness: { scope: :parent_container_id }

  scope :by_path, -> (paths) {
    normalized_paths = Array(paths).map {|p| Redesign::Container.normalize_slug(p)}
    where('path in (?)',  normalized_paths).order("field(path, '#{normalized_paths.join('\',\'')}')")
  }

  scope :by_ids_with_descendants, ->(ids) {
    where(arel_table[:id].in(ids).or(arel_table[:parent_container_id].in(ids)))
  }

  def self.normalize_slug(raw)
    '/' + raw.to_s.downcase.strip.gsub(LEADING_OR_TRAILING_SLASH, '')
  end

  def self.lookup(layout, slug = '/')
    where(layout: layouts[layout], slug: normalize_slug(slug)).
      includes(:public_payload, :draft_payload).
      first
  end

  def slug=(raw)
    write_attribute :slug, Redesign::Container.normalize_slug(raw)
  end

  def path=(raw)
    write_attribute :path, Redesign::Container.normalize_slug(raw)
  end

  def data=(raw_draft_data)
    payload_data = payload_validator.new(raw_draft_data)

    if payload_data.valid?
      @draft_payload_data = payload_data.as_json
    else
      @draft_payload_errors = payload_data.errors
    end
  end

  def payload_validator
    @payload_validator ||= ("#{layout.to_s.classify}Layout".constantize)
  end

  def payload(draft = false)
    if draft
      draft_payload
    else
      public_payload
    end
  end

  def child_containers
    Redesign::Container.where(parent_container_id: id).order(:path)
  end

  def branch_ids
    tree_path.to_s.split(',').map(&:to_i)
  end

  def recache_parent_container_child_containers_count
    return unless parent_container
    parent_container.cache_child_containers_count
  end

  def cache_child_containers_count
    update_column :child_containers_count, child_containers.count
  end

  def reassociate_child_containers_to_next_parent
    child_containers.update_all(parent_container_id: parent_container_id)
    true
  end

  def schedule_notify_previous_parent_of_child_association_change
    return unless parent_container_id_changed?
    return unless previous_parent_id = parent_container_id_was
    @previous_parent = Redesign::Container.find(previous_parent_id)
    true
  end

  def notify_previous_parent_of_child_association_change
    return unless @previous_parent
    @previous_parent.cache_child_containers_count
    true
  end

  protected

  def update_draft_payload
    return true unless @draft_payload_data

    if draft_payload
      draft_payload.update(data: @draft_payload_data)
    else
      update_column :draft_payload_id, payloads.create!(data: @draft_payload_data).id
    end
  end

  def validate_draft_payload
    return true unless @draft_payload_errors
    errors.add :data, 'is not a valid payload'
  end
end
