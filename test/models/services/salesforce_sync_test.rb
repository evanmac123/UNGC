require 'test_helper'

class SalesforceSyncTest < ActiveSupport::TestCase

  context 'creating records' do

    should 'create a new campaign' do
      job = create_campaign_job
      assert_difference 'Campaign.count', +1 do
        SalesforceSync.sync([job])
      end
    end

    should 'create a new contribution' do
      job = create_contribution_job
      assert_difference 'Contribution.count', +1 do
        SalesforceSync.sync([job])
      end
    end

  end

  context 'updating records' do

    should 'update an existing campaign' do
      campaign = create(:campaign)
      job = create_campaign_job(campaign: campaign, name: 'new-name')

      assert_no_difference 'Campaign.count' do
        SalesforceSync.sync([job])
      end

      assert_equal 'new-name', campaign.reload.name
    end

    should 'update an existing contribution' do
      contribution = create(:contribution)

      job = create_contribution_job(
        contribution: contribution,
        raw_amount: 27,
      )

      assert_no_difference 'Contribution.count' do
        SalesforceSync.sync([job])
      end

      assert_equal 27, contribution.reload.raw_amount
    end

  end

  context 'records that have never been synced' do

    should 'raise on invalid campaign data' do
      assert_raise ActiveRecord::RecordInvalid do
        SalesforceSync.sync([
          type: 'campaign',
          id: 'fake-campaign',
          is_deleted: false,
        ])
      end
    end

    should 'raise on invalid contribution data' do
      assert_raise ActiveRecord::RecordInvalid do
        SalesforceSync.sync([
          type: 'contribution',
          id: 'fake-contribution',
          is_deleted: false,
        ])
      end
    end

    should 'ignore campaigns deletes' do
      campaign = create(:campaign)
      job = create_campaign_job(campaign: campaign, is_deleted: true)
      assert_no_difference 'Campaign.count' do
        SalesforceSync.sync([job])
      end
    end

    should 'ignore contributions deletes' do
      contribution = create(:contribution)
      job = create_contribution_job(contribution: contribution, is_deleted: true)
      assert_no_difference 'Contribution.count' do
        SalesforceSync.sync([job])
      end
    end

  end

  private

  def create_campaign_job(params = {})
    campaign = params.fetch(:campaign) { build_stubbed(:campaign) }
    {
      type: params.fetch(:type, "campaign"),
      id: params.fetch(:id, campaign.campaign_id),
      name: params.fetch(:name, campaign.name),
      start_date: params.fetch(:start_date, "2017-01-01"),
      end_date: params.fetch(:end_date, "2017-02-02"),
      is_deleted: params.fetch(:is_deleted, false),
      is_private: params.fetch(:is_private, false),
    }
  end

  def create_contribution_job(params = {})
    contribution = params.fetch(:contribution) { build_stubbed(:contribution) }
    {
      type: params.fetch(:type, "contribution"),
      id: params.fetch(:id, contribution.id),
      organization_id: params.fetch(:organization_id, contribution.organization_id.to_s),
      stage: params.fetch(:stage, contribution.stage),
      date: params.fetch(:date, "2017-10-01"),
      is_deleted: params.fetch(:is_deleted, false),
      campaign_id: params.fetch(:campaign_id, contribution.campaign_id),
      invoice_code: params.fetch(:invoice_code, "AP"),
      recognition_amount: params.fetch(:recognition_amount, nil),
      raw_amount: params.fetch(:raw_amount, 20000.0),
      payment_type: params.fetch(:payment_type, nil),
    }
  end

end
