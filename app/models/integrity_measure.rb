class IntegrityMeasure < ActiveRecord::Base
  TYPES = { :cop      => 'Communication on Progress',
            :logo     => 'Network Logo Policy',
            :dialogue => 'Dialogue Faciliation' }

  belongs_to :local_network
  has_one :attachment, :class_name => 'UploadedFile', :as => :attachable
end

