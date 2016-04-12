class Issue < ActiveRecord::Base
  validates_presence_of :name

  belongs_to :parent, class_name: 'Issue'
  has_many :children, class_name: 'Issue', foreign_key: :parent_id

  scope :children, -> { where(type: nil) }

  def is_parent?
    self.parent_id.nil?
  end
end
