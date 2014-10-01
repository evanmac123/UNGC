class ContributionDescription < ActiveRecord::Base
  belongs_to :local_network
  attr_accessible :pledge, :pledge_continued, :payment, :contact, :additional, :local_network_id
  validates :local_network_id, presence: true

  def no_description_completed?
   pledge.blank? &&
   pledge_continued.blank? &&
   payment.blank? &&
   contact.blank? &&
   additional.blank?
  end

  def self.local_network_model_type
    :contribution_description
  end

end
