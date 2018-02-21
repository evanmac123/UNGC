# frozen_string_literal: true
# == Schema Information
#
# Table name: organization_social_networks
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  network_code    :string(30)       not null
#  handle          :string(50)       not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#


class OrganizationSocialNetwork < ActiveRecord::Base
  NETWORKS = %w[twitter].freeze

  belongs_to :organization, inverse_of: :social_network_handles

  validates :network_code,
            presence: true,
            inclusion: { in: NETWORKS,
                         message: '%{value} is not a recognized social network code' }
  validate :network_unique?

  validates :handle,
            presence: true,
            length: { maximum: 50 },
            uniqueness: { scope: :network_code,
                          message: 'is already used by another organization' }

  default_scope { order(:network_code) }

  def self.ordered
    in_order = %w[twitter]
    reorder(AnsiSqlHelper.fields_as_case('organization_social_networks.network_code', in_order))
  end

  def self.for_network(network)
    find_by(network_code: network)
  end

  def network_unique?
    any_other = organization.social_network_handles.where(network_code: network_code)
    errors[:organization] << 'already has an account for the Social Network' if network_code_changed? && any_other.exists?
  end
end
