# == Schema Information
#
# Table name: contribution_levels_infos
#
#  id                     :integer          not null, primary key
#  local_network_id       :integer
#  level_description      :string(255)
#  amount_description     :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  pledge_description     :string(255)
#  payment_description    :string(255)
#  contact_description    :string(255)
#  additional_description :string(255)
#

class ContributionLevelsInfo < ActiveRecord::Base
  include Enumerable

  belongs_to :local_network
  has_many :levels, class_name: 'ContributionLevel'
  attr_accessible :amount_description,
                  :level_description,
                  :local_network_id,
                  :pledge_description,
                  :payment_description,
                  :contact_description,
                  :additional_description
  
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
