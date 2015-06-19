require 'test_helper'

class ParticipantCampaignContributionsByYearTest < ActiveSupport::TestCase

  should "include public campaigns" do
    assert_includes campaigns, public_campaign
  end

  should "not include private campaigns" do
    assert_not_includes campaigns, private_campaign
  end

  should "only show years for which there are public contributions" do
    assert_includes contribution_years, 2011
    assert_not_includes contribution_years, 2012
  end

  private

  def participant
    @organization ||= begin
      create_organization_type
      create_organization(participant: true).tap do |organization|

        create_contribution(
          organization: organization,
          campaign: private_campaign,
          stage: Contribution::STAGE_POSTED,
          date: Date.new(2012, 1, 1)
        )

        create_contribution(
          organization: organization,
          campaign: public_campaign,
          stage: Contribution::STAGE_POSTED,
          date: Date.new(2011, 2, 2)
        )

        organization.reload
      end
    end
  end

  def contributions
    @contributions ||= ParticipantCampaignContributionsByYear.for(participant)
  end

  def campaigns
    contributions.flat_map(&:last)
  end

  def contribution_years
    contributions.flat_map(&:first)
  end

  def contribute(organization, campaign)

  end

  def private_campaign
    @private_campaign ||= create_campaign(is_private: true)
  end

  def public_campaign
    @public_campaign ||= create_campaign
  end

end
