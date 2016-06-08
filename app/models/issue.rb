# == Schema Information
#
# Table name: issues
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  type       :string(255)
#  parent_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Issue < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :parent, class_name: 'Issue'
  has_many :children, class_name: 'Issue', foreign_key: :parent_id

  scope :children, -> { where(type: nil) }

  def is_parent?
    self.parent_id.nil?
  end
end
