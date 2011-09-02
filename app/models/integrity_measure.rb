# == Schema Information
#
# Table name: integrity_measures
#
#  id               :integer(4)      not null, primary key
#  local_network_id :integer(4)
#  title            :string(255)
#  policy_type      :string(255)
#  description      :text
#  date             :date
#

class IntegrityMeasure < ActiveRecord::Base
  TYPES = { :cop      => 'Communication on Progress',
            :logo     => 'Network Logo Policy',
            :dialogue => 'Dialogue Faciliation' }

  belongs_to :local_network
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
end

