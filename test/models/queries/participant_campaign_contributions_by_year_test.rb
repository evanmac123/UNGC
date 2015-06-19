require 'test_helper'

class ParticipantCampaignContributionsByYearTest < ActiveSupport::TestCase

  should "include public campaigns" do
    assert_includes campaigns, public_campaign
  end

  should "not include private campaigns" do
    assert_not_includes campaigns, private_campaign
  end

  private

  def participant
    @organization ||= begin
      create_organization_type
      create_organization(participant: true).tap do |organization|
        contribute(organization, private_campaign)
        contribute(organization, public_campaign)
        organization.reload
      end
    end
  end

  def campaigns
    @campaigns ||= ParticipantCampaignContributionsByYear.for(participant).flat_map(&:last)
  end

  def contribute(organization, campaign)
    create_contribution(
      organization: organization,
      campaign: campaign,
      stage: Contribution::STAGE_POSTED
    )
  end

  def private_campaign
    @private_campaign ||= create_campaign(is_private: true)
  end

  def public_campaign
    @public_campaign ||= create_campaign
  end

end
