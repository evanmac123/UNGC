class Topic < Principle

  acts_as_tree order:'parent_id'
  has_and_belongs_to_many :resources

end