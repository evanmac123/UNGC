# == Schema Information
#
# Table name: awards
#
#  id               :integer(4)      not null, primary key
#  local_network_id :integer(4)
#  title            :string(255)
#  description      :text
#  type             :string(255)
#  date             :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Award < ActiveRecord::Base
  TYPES = { :cop          => 'Communication on Progress',
            :principles   => 'Global Compact - Ten Principles',
            :partnerships => 'Partnerships for Development' }

  belongs_to :local_network
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
end

