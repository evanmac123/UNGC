# == Schema Information
#
# Table name: uploaded_files
#
#  id                      :integer(4)      not null, primary key
#  attachable_id           :integer(4)
#  attachable_type         :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_file_size    :integer(4)
#  attachment_content_type :string(255)
#  attachment_updated_at   :datetime
#

class UploadedFile < ActiveRecord::Base
  belongs_to :attachable, :polymorphic => true
  has_attached_file :attachment
end
