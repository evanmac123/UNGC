class Author < ActiveRecord::Base
  has_and_belongs_to_many :resources
  default_scope order(:full_name)

  def self.for_approved_resources
    Author.joins(:resources).where("resources.approval='approved'")
  end
end
