class Resource < ActiveRecord::Base

  include ContentApproval

  has_and_belongs_to_many :principles
  has_and_belongs_to_many :authors
  has_many :resource_links
end
