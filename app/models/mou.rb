class MOU < ActiveRecord::Base
  include HasFile
  belongs_to :local_network

  validates_inclusion_of :year, :in => 2000..Date.today.year, :allow_nil => false
end

