class ContributionLevelsInfo < ActiveRecord::Base
  include Enumerable

  belongs_to :local_network
  has_many :levels, class_name: 'ContributionLevel'
  attr_accessible :amount_description, :level_description, :local_network_id

  validates :local_network_id, presence: true

  def add(args)
    unless args.has_key?(:description) && args.has_key?(:amount)
      Rails.logger.error 'ContributionLevelsInfo#add must have description and amount'
      return
    end

    levels.build(args)
  end

  def each(&block)
    levels.each(&block)
  end

  def empty?
    levels.empty? && amount_description.nil? && level_description.nil?
  end

end
