class Author < ActiveRecord::Base
  has_and_belongs_to_many :resources
  default_scope order(:full_name)
end
