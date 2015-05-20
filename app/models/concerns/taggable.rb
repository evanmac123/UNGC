module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings,       dependent: :destroy
    has_many :sectors,        through: :taggings
    has_many :sector_groups,  through: :sectors, class_name: 'Sector', source: :parent
    has_many :issues,         through: :taggings
    has_many :issue_areas,    through: :issues, class_name: 'Issue', source: :parent
    has_many :topics,         through: :taggings
    has_many :topic_groups,   through: :topics, class_name: 'Topic', source: :parent
  end

end
