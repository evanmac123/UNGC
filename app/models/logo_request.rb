# == Schema Information
#
# Table name: logo_requests
#
#  id                :integer(4)      not null, primary key
#  old_id            :integer(4)
#  requested_on      :date
#  status_changed_on :date
#  publication_id    :integer(4)
#  organization_id   :integer(4)
#  contact_id        :integer(4)
#  reviewer_id       :integer(4)
#  replied_to        :boolean(1)
#  purpose           :string(255)
#  status            :string(255)
#  accepted          :boolean(1)
#  accepted_on       :date
#  created_at        :datetime
#  updated_at        :datetime
#

class LogoRequest < ActiveRecord::Base
  validates_presence_of :organization_id, :requested_on, :publication_id
  belongs_to :organization
  belongs_to :contact
  belongs_to :publication, :class_name => "LogoPublication"
  has_many :logo_comments
end
