require 'test_helper'

class SalesforceSyncTest < ActiveSupport::TestCase

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
