# == Schema Information
#
# Table name: comments
#
#  id                      :integer         not null, primary key
#  body                    :text            default("")
#  commentable_id          :integer
#  commentable_type        :string(255)
#  contact_id              :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true
  default_scope :order => 'created_at ASC'
  belongs_to :contact
  
  has_attached_file :attachment
end
