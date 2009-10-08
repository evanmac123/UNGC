# == Schema Information
#
# Table name: uploaded_files
#
#  id              :integer(4)      not null, primary key
#  size            :integer(4)
#  content_type    :string(255)
#  filename        :string(255)
#  attachable_id   :integer(4)
#  attachable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class UploadedFile < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  
  has_attachment  :content_type => ["application/msword", "application/pdf", "application/vnd.mozilla.xul+xml", "application/vnd.ms-excel", "application/vnd.ms-powerpoint", "application/x-shockwave-flash", "application/xhtml+xml", "application/xml", "application/zip", "image/gif", "image/jpeg", "image/png", "image/svg+xml", "image/tiff", "image/x-xwindowdump", "text/calendar", "text/html", "text/plain", "video/mp4", "video/mpeg", "video/quicktime"],
                  :storage      => :file_system, 
                  :path_prefix  => 'public/uploaded_files'
end
