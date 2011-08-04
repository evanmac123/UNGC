class Award < ActiveRecord::Base
  belongs_to :local_network
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
end

