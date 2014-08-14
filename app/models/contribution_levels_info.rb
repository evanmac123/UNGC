class ContributionLevelsInfo < ActiveRecord::Base
  include Enumerable

  belongs_to :local_network
  has_many :contribution_levels
  attr_accessible :amount_description, :level_description, :local_network_id

  validates :local_network_id, presence: true

  def add(args)
    unless args.has_key?(:description) && args.has_key?(:amount)
      Rails.logger.error 'ContributionLevelsInfo#add must have description and amount'
      return
    end

    level = ContributionLevel.new(args.merge(contribution_levels_info_id: self.id))
    contribution_levels << level
  end

  def each(&block)
    contribution_levels.each(&block)
  end

end
