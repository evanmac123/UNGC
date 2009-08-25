class Exchange < ActiveRecord::Base
  validates_presence_of :name, :code
  belongs_to :country
end
