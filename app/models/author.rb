# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  full_name  :string(255)
#  acronym    :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Author < ActiveRecord::Base
  has_and_belongs_to_many :resources
  default_scope order(:full_name)

  def self.for_approved_resources
    Author.joins(:resources).where("resources.approval='approved'").group('authors.id')
  end
end
