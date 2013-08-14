class Resource < ActiveRecord::Base
  validates_presence_of :title, :description

  include ContentApproval

  has_and_belongs_to_many :principles
  has_and_belongs_to_many :authors
  has_many :links,
    dependent: :destroy,
    class_name: 'ResourceLink'
end
