class LocalNetworkEvent < ActiveRecord::Base
  belongs_to :local_network
  has_and_belongs_to_many :principles
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
end

