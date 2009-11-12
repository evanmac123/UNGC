# == Schema Information
#
# Table name: cop_files
#
#  id                      :integer(4)      not null, primary key
#  cop_id                  :integer(4)
#  name                    :string(255)
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer(4)
#  attachment_updated_at   :datetime
#  created_at              :datetime
#  updated_at              :datetime
#

class CopFile < ActiveRecord::Base
  validates_presence_of :name
  belongs_to :communication_on_progress, :foreign_key => :cop_id

  has_attached_file :attachment
end
