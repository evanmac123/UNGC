# == Schema Information
#
# Table name: announcements
#
#  id               :integer(4)      not null, primary key
#  local_network_id :integer(4)
#  title            :string(255)
#  description      :string(255)
#  date             :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Announcement < ActiveRecord::Base
  belongs_to :local_network
  belongs_to :principle

  validates_presence_of :title, :description, :date

  delegate :name, :to => :principle, :prefix => true
  delegate :name, :region_name, :to => :local_network, :prefix => true

  default_scope :order => :date

  def self.local_network_model_type
    :knowledge_sharing
  end

  def readable_error_messages
    error_messages = []
    errors.each do |error|
      case error
        when 'file'
          error_messages << 'Choose a file to upload'
        when 'title'
          error_messages << 'Title is required'
        when 'description'
          error_messages << 'Provide a brief description for the event'
      end
    end
    error_messages
  end

  private

    def set_type
      self.mou_type = 'in_review' unless mou_type.present?
    end

end

