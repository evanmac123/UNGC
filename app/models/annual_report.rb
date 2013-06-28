# == Schema Information
#
# Table name: annual_reports
#
#  id               :integer          not null, primary key
#  local_network_id :integer
#  year             :date
#  future_plans     :boolean
#  activities       :boolean
#  financials       :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

class AnnualReport < ActiveRecord::Base
  include HasFile
  belongs_to :local_network

  default_scope :order => 'year DESC'

  def self.local_network_model_type
    :network_management
  end

  def readable_error_messages
    error_messages = []
    errors.each do |error|
      case error
        when :file
          error_messages << 'Choose a file to upload'
       end
    end
    error_messages
  end

end

