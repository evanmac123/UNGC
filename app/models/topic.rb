class Topic < Principle

  acts_as_tree order:'parent_id'

end