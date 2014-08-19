class ContributionLevelsInfo < ActiveRecord::Base
  include Enumerable

  belongs_to :local_network
  has_many :contribution_levels
  attr_accessible :amount_description, :level_description, :local_network_id, :contribution_levels_attributes

  accepts_nested_attributes_for :contribution_levels, allow_destroy: true

  validates :local_network_id, presence: true

  def add(args)
    unless args.has_key?(:description) && args.has_key?(:amount)
      Rails.logger.error 'ContributionLevelsInfo#add must have description and amount'
      return
    end

    contribution_levels.build(args)
  end

  def each(&block)
    contribution_levels.each(&block)
  end

  def empty?
    contribution_levels.empty? && amount_description.nil? && level_description.nil?
  end

end
