class Topic < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :parent, class_name: 'Topic'
  has_many :children, class_name: 'Topic', foreign_key: :parent_id

  scope :children, -> { where.not(parent_id: nil) }

  def is_parent?
    self.parent_id.nil?
  end
end
