# == Schema Information
#
# Table name: resources
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  description    :text
#  year           :date
#  image_url      :string(255)
#  isbn           :string(255)
#  approval       :string(255)
#  approved_at    :datetime
#  approved_by_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  views          :integer          default(0)
#

class Resource < ActiveRecord::Base
  attr_accessible :title, :description, :year, :isbn, :image_url, :principle_ids, :author_ids, :image
  has_attached_file :image, :styles => {
      :show => "213x277>",
      :'show@2x' => "425x554>",
      :featured => "141x183>",
      :'featured@2x' => "282x366>",
      :result => "130x169>",
      :'result@2x' => "260x338>"
    },
    :url => "/system/:class/:attachment/:id/:style/:filename"

  validates_presence_of :title, :description
  #validates_attachment_content_type :image, content_type: /image/

  include ContentApproval

  has_and_belongs_to_many :principles
  has_and_belongs_to_many :authors
  has_many :links, dependent: :destroy, class_name: 'ResourceLink'

  STATES = { pending:    'Pending Review',
             approved:   'Approved',
             previously: 'Archived'
           }

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
    has links.language(:id), :as => :language_ids, facet: true

    where "approval = 'approved'"

    #has link(:id), :as => :link_ids, :facet => true
    # TODO index link titles
    set_property :enable_star => true
    set_property :min_prefix_len => 4
  end

  def increment_views!
    self.increment! :views
  end

  def approval_name
    STATES[approval.to_sym]
  end

  def cover_image(size = nil, options={})
    if options[:retina]
      image.exists? ? image.url(size.to_s + '@2x') : image_url
    else
      image.exists? ? image.url(size) : image_url
    end
  end

end
