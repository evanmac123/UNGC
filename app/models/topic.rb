# == Schema Information
#
# Table name: topics
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Topic < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :parent, class_name: 'Topic'
  has_many :children, class_name: 'Topic', foreign_key: :parent_id

  default_scope { order(:id) }
  scope :children, -> { where.not(parent_id: nil) }

  def is_parent?
    self.parent_id.nil?
  end
end
