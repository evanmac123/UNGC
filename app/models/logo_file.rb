# == Schema Information
#
# Table name: logo_files
#
#  id                   :integer          not null, primary key
#  name                 :string(255)
#  description          :string(255)
#  old_id               :integer
#  thumbnail            :string(255)
#  file                 :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#  zip_file_name        :string(255)
#  zip_content_type     :string(255)
#  zip_file_size        :integer
#  zip_updated_at       :datetime
#  preview_file_name    :string(255)
#  preview_content_type :string(255)
#  preview_file_size    :integer
#  preview_updated_at   :datetime
#

class LogoFile < ActiveRecord::Base
  validates_presence_of :name, :thumbnail
  has_and_belongs_to_many :logo_requests

  has_attached_file :zip,
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"
  has_attached_file :preview,
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"
end
