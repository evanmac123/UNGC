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
end
