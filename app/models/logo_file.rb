# == Schema Information
#
# Table name: logo_files
#
#  id               :integer(4)      not null, primary key
#  name             :string(255)
#  description      :string(255)
#  old_id           :integer(4)
#  thumbnail        :string(255)
#  file             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  zip_file_name    :string(255)
#  zip_content_type :string(255)
#  zip_file_size    :integer(4)
#  zip_updated_at   :datetime
#

class LogoFile < ActiveRecord::Base
  validates_presence_of :name, :file, :thumbnail
  has_and_belongs_to_many :logo_requests
  
  has_attached_file :zip
end
