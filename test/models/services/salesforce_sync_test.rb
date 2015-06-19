require 'test_helper'

class SalesforceSyncTest < ActiveSupport::TestCase

  context 'Campaign' do
    # see lib/salesforce/classes/UngcCampaignSerializer.apex for fields

    setup do
      @campaign = create_campaign
      @job = {type: 'campaign'}
      .merge(@campaign.attributes)
      .merge(id: @campaign.id)
      .with_indifferent_access
    end

    should 'include name' do
      assert SalesforceSync.sync [@job.merge(name: 'super-campaign')]
      assert_equal 'super-campaign', @campaign.reload.name
    end

    should 'include start_date' do
      assert SalesforceSync.sync [@job.merge(start_date: '2015-06-17')]
      assert_equal Date.new(2015,6,17), @campaign.reload.start_date
    end

    should 'include end_date' do
      assert SalesforceSync.sync [@job.merge(end_date: '2015-06-17')]
      assert_equal Date.new(2015,6,17), @campaign.reload.end_date
    end

    should 'allow null start_date' do
      assert SalesforceSync.sync [@job.merge(start_date: nil)]
      assert_nil @campaign.reload.start_date
    end

    should 'allow null end_date' do
      assert SalesforceSync.sync [@job.merge(start_date: nil)]
      assert_nil @campaign.reload.end_date
    end

    should 'include is_deleted' do
      assert SalesforceSync.sync [@job.merge(is_deleted: true)]
      assert_equal true, @campaign.reload.is_deleted
    end

  end

  context 'Contribution' do

    setup do
      create_organization_type # required for test setup =\
      @contribution = create_contribution
      @job = {type: 'contribution'}
      .merge(@contribution.attributes)
      .merge(id: @contribution.id)
      .with_indifferent_access
    end

    should 'include organization_id' do
      organization = create_organization
      assert SalesforceSync.sync [@job.merge(organization_id: organization.id)]
      assert_equal organization.id, @contribution.reload.organization_id
    end

    should 'include stage' do
      assert SalesforceSync.sync [@job.merge(stage: 'Prospecting')]
      assert_equal 'Prospecting', @contribution.reload.stage
    end

    should 'include date' do
      assert SalesforceSync.sync [@job.merge(date: '2015-06-17')]
      assert_equal Date.new(2015,6,17), @contribution.reload.date
    end

    should 'include is_deleted' do
      assert SalesforceSync.sync [@job.merge(is_deleted: true)]
      assert_equal true, @contribution.reload.is_deleted
    end

    should 'include campaign_id' do
      campaign = create_campaign
      assert SalesforceSync.sync [@job.merge(campaign_id: campaign.id)]
      assert_equal campaign.id, @contribution.reload.campaign_id
    end

    should 'allow null campaign_id' do
      assert SalesforceSync.sync [@job.merge(campaign_id: nil)]
      assert_nil @contribution.reload.campaign_id
    end

    should 'include invoice_code' do
      assert SalesforceSync.sync [@job.merge(invoice_code: 'FGCX')]
      assert_equal 'FGCX', @contribution.reload.invoice_code
    end

    should 'allow null invoice_code' do
      assert SalesforceSync.sync [@job.merge(invoice_code: nil)]
      assert_nil @contribution.reload.invoice_code
    end

    should 'include recognition_amount' do
      assert SalesforceSync.sync [@job.merge(recognition_amount: 30000)]
      assert_equal 30000, @contribution.reload.recognition_amount
    end

    should 'allow null recognition_amount' do
      assert SalesforceSync.sync [@job.merge(recognition_amount: nil)]
      assert_nil @contribution.reload.recognition_amount
    end

    should 'include raw_amount' do
      assert SalesforceSync.sync [@job.merge(raw_amount: 30001)]
      assert_equal 30001, @contribution.reload.raw_amount
    end

    should 'allow null raw_amount' do
      assert SalesforceSync.sync [@job.merge(raw_amount: nil)]
      assert_nil @contribution.reload.raw_amount
    end

    should 'include payment_type' do
      assert SalesforceSync.sync [@job.merge(payment_type: 'CC-VS/MC/DS')]
      assert_equal 'CC-VS/MC/DS', @contribution.reload.payment_type
    end

    should 'allow null payment_type' do
      assert SalesforceSync.sync [@job.merge(payment_type: nil)]
      assert_nil @contribution.reload.payment_type
    end

  end

  context 'creating records' do

    should 'create a new campaign' do
      job = valid_campaign_attributes.merge(type: 'campaign')
      assert_difference 'Campaign.count', +1 do
        SalesforceSync.sync([job])
      end
    end

    should 'create a new contribution' do
      create_organization_type # required for test setup =\
      job = valid_contribution_attributes.merge(type: 'contribution')
      assert_difference 'Contribution.count', +1 do
        SalesforceSync.sync([job])
      end
    end

  end

  context 'updating records' do

    should 'update an existing campaign' do
      campaign = create_campaign
      job = {
        id: campaign.id,
        type: 'campaign',
        name: 'new-name',
      }
      assert_no_difference 'Campaign.count' do
        SalesforceSync.sync([job])
      end

      assert_equal 'new-name', campaign.reload.name
    end

    should 'update an existing contribution' do
      create_organization_type # required for test setup =\
      contribution = create_contribution
      job = {
        id: contribution.id,
        type: 'contribution',
        raw_amount: 27,
      }
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
      assert_no_difference 'Campaign.count' do
        SalesforceSync.sync([{
          type: "campaign",
          id: "fake-campaign",
          is_deleted: true
        }])
      end
    end

    should 'ignore contributions deletes' do
      assert_no_difference 'Contribution.count' do
        SalesforceSync.sync([{
          type: "contribution",
          id: "fake-contribution",
          is_deleted: true
        }])
      end
    end

  end

end
