class ContributionDescription < ActiveRecord::Base
  belongs_to :local_network
  attr_accessible :pledge, :pledge_continued, :payment,
                  :contact, :additional, :local_network_id

  validates :local_network_id,  presence: true
  validates :pledge,            length: { maximum: 500 }
  validates :pledge_continued,  length: { maximum: 500 }
  validates :additional,        length: { maximum: 500 }

  def empty?
    [
      :pledge,
      :pledge_continued,
      :payment,
      :contact,
      :additional
    ].all? {|field| public_send(field).blank? }
  end

  # LocalNetworkSubmodelController required methods

  def self.local_network_model_type
    :contribution_description
  end

  def readable_error_messages
    errors.full_messages
  end

end
