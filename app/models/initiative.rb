class Initiative < ActiveRecord::Base
  has_many :signings
  has_many :signatories, :through => :signings
end
