class Resource < ActiveRecord::Base
  attr_accessible :title, :description, :year, :isbn, :image_url, :principle_ids, :author_ids

  validates_presence_of :title, :description

  include ContentApproval

  has_and_belongs_to_many :principles
  has_and_belongs_to_many :authors
  has_many :links, dependent: :destroy, class_name: 'ResourceLink'

  def self.with_principles_count
    select("resources.*, count(principles_resources.principle_id) as principles_count")
    .joins("LEFT OUTER JOIN `principles_resources` ON resources.id=principles_resources.resource_id")
    .group('resources.id')
  end
  
  cattr_reader :per_page
  @@per_page = 400

  define_index do
    indexes :title, :sortable => true
    indexes :description, :sortable => true
    indexes :year, :sortable => true
    indexes links.title, :as => "link_title", :sortable => true

    has authors(:id),     :as => :authors_ids, :facet => true
    has principles(:id),     :as => :principle_ids, :facet => true
    has links.language(:id), :as => :language_id

    where "approval = 'approved'"

    #has link(:id), :as => :link_ids, :facet => true
    # TODO index link titles
    set_property :enable_star => true
    set_property :min_prefix_len => 4
  end


end
