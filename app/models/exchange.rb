# == Schema Information
#
# Table name: exchanges
#
#  id             :integer(4)      not null, primary key
#  code           :string(255)
#  name           :string(255)
#  secondary_code :string(255)
#  terciary_code  :string(255)
#  country_id     :integer(4)
#  created_at     :datetime
#  updated_at     :datetime
#

class Exchange < ActiveRecord::Base
  validates_presence_of :name, :code
  belongs_to :country
end
