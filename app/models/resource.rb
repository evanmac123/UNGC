# == Schema Information
#
# Table name: resources
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  year               :date
#  isbn               :string(255)
#  approval           :string(255)
#  approved_at        :datetime
#  approved_by_id     :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  views              :integer          default(0)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class Resource < ActiveRecord::Base
  include Indexable

  has_attached_file :image, :styles => {
      :show => "213x277>",
      :'show@2x' => "425x554>",
      :featured => "141x183>",
      :'featured@2x' => "282x366>",
      :result => "130x169>",
      :'result@2x' => "260x338>"
    },
    :url => "/system/:class/:attachment/:id/:style/:filename"

  permalink :name_for_permalink

  validates_presence_of :title, :description
  do_not_validate_attachment_file_type :image

  include ContentApproval

  has_and_belongs_to_many :principles
  has_and_belongs_to_many :authors
  has_many :links, dependent: :destroy, class_name: 'ResourceLink'
  has_many :languages, through: :links

  has_many :taggings
  has_many :sectors,        through: :taggings
  has_many :sector_groups,  through: :sectors, source: :parent
  has_many :issues,         through: :taggings
  has_many :issue_areas,    through: :issues, class_name: 'Issue', source: :parent
  has_many :topics,         through: :taggings
  has_many :topic_groups,   through: :topics, class_name: 'Topic', source: :parent

  STATES = { pending:    'Pending Review',
             approved:   'Approved',
             previously: 'Archived'
           }
  enum content_type: [ :academic_literature,
                       :case_example,
                       :guidance,
                       :meeting_report,
                       :newsletter,
                       :un_global_compact_report,
                       :toolkit,
                       :webinar,
                       :presentation,
                       :website,
                       :video]

  scope :update_required, lambda { where("content_type IS NULL") }

  def self.with_principles_count
    select("resources.*, count(principles_resources.principle_id) as principles_count")
    .joins("LEFT OUTER JOIN `principles_resources` ON resources.id=principles_resources.resource_id")
    .group('resources.id')
  end

  cattr_reader :per_page
  @@per_page = 400

  def increment_views!
    self.increment! :views
  end

  def approval_name
    STATES[approval.to_sym]
  end

  def cover_image(size = nil, options={})
    if options[:retina]
      image.url(size.to_s + '@2x')
    else
      image.url(size)
    end
  end

  def self.search(*args)
    results = super *args
    if results && results.total_entries
      results
    else
      raise Riddle::ConnectionError
    end
  end

  def name_for_permalink
    self.title.parameterize
  end

end
