require 'test_helper'

class Salesforce::ApiControllerTest < ActionController::TestCase

  def auth_with_token(token)
    @request.env['HTTP_AUTHORIZATION'] = "Token token=#{token}"
  end

  def auth_with_vaild_token
    auth_with_token '16d7d6089b8fe0c5e19bfe10bb156832'
  end

  def sync(*jobs)
    auth_with_vaild_token
    params = {"_json" => jobs}
    post :sync, api: params, format: :json
  end

  def campaign_attributes(params = {})
    defaults = {
      'id' => SecureRandom.uuid,
      'type' => 'campaign',
      'name' => Faker::Name.name,
    }
    defaults.merge(params)
  end

  def send_create_campaign(params = {})
    attrs = campaign_attributes(params).with_indifferent_access
    id = attrs[:id]
    sync(attrs)
    Campaign.find_by_campaign_id(id)
  end

  def send_update_campaign(params = {})
    id = params[:id] || @id
    sync({"id" => id, "type" => 'campaign'}.merge(params))
    Campaign.find_by_campaign_id(id)
  end

  def contribution_attributes(params = {})
    defaults = {
      'id' => SecureRandom.uuid,
      'type' => 'contribution',
      'date' => Date.today - rand(999).days,
      'stage' => 'posted',
      'organization_id' => @organization.id
    }
    defaults.merge(params)
  end

  def send_create_contribution(params = {})
    attrs = contribution_attributes(params).with_indifferent_access
    id = attrs[:id]
    sync(attrs)
    Contribution.find_by(contribution_id: id)
  end

  def send_update_contribution(params = {})
    id = params[:id] || @id
    sync({"id" => id, "type" => 'contribution'}.merge(params))
    Contribution.find_by(contribution_id: id)
  end

  context "Campaigns" do
    context "create" do
      should 'have the given id' do
        campaign = send_create_campaign(id:'123')
        assert_equal '123', campaign.campaign_id
        assert_equal '123', campaign.id
      end

      should 'have the given name' do
        campaign = send_create_campaign(name:'super campaign')
        assert_equal 'super campaign', campaign.name
      end
    end

    context "update" do
      setup do
        @id = create(:campaign,
          start_date: Date.new(2013, 8, 25),
          end_date: Date.new(2013, 8, 25),
          is_private: false
        ).campaign_id
      end

      should 'update name' do
        updated = send_update_campaign(name: 'new name')
        assert_equal 'new name', updated.name
      end

      should 'update start_date' do
        today = Date.today
        updated = send_update_campaign(start_date: today)
        assert_equal today, updated.start_date
      end

      should 'update end_date' do
        today = Date.today
        updated = send_update_campaign(end_date: today)
        assert_equal today, updated.end_date
      end

      should 'update is_private' do
        updated = send_update_campaign(is_private: true)
        assert_equal true, updated.private?
      end

      context "nullable fields" do
        should 'allow null start_date' do
          updated = send_update_campaign(end_date: 'NULL')
          assert_nil updated.end_date
        end

        should 'allow null end_date' do
          updated = send_update_campaign(end_date: 'NULL')
          assert_nil updated.end_date
        end
      end
    end

    should 'mark as deleted' do
      campaign = create(:campaign)
      updated = send_update_campaign(id: campaign.campaign_id, is_deleted: true)
      assert_equal true, updated.is_deleted
    end

    should 'mark as undeleted' do
      campaign = create(:campaign, is_deleted: true)
      updated = send_update_campaign(id: campaign.campaign_id, is_deleted: false)
      assert_equal false, updated.is_deleted
    end
  end

  context "Contributions" do
    setup do
      create_organization_and_user
      @campaign = create(:campaign)
    end

    context "create" do
      should 'have the given id' do
        contribution = send_create_contribution(id: 'contribution_id')
        assert_equal 'contribution_id', contribution.contribution_id
        assert_equal 'contribution_id', contribution.contribution_id
      end

      should 'have the given invoice_code' do
        contribution = send_create_contribution(invoice_code: 'invoice_code')
        assert_equal 'invoice_code', contribution.invoice_code
      end

      should 'have the given raw_amount' do
        contribution = send_create_contribution(raw_amount: 30)
        assert_equal 30, contribution.raw_amount
      end

      should 'have the given recognition_amount' do
        contribution = send_create_contribution(recognition_amount: 20)
        assert_equal 20, contribution.recognition_amount
      end

      should 'have the given date' do
        today = Date.today
        contribution = send_create_contribution(date: today)
        assert_equal today, contribution.date
      end

      should 'have the given stage' do
        contribution = send_create_contribution(stage: 'stage')
        assert_equal 'stage', contribution.stage
      end

      should 'have the given payment_type' do
        contribution = send_create_contribution(payment_type: 'payment_type')
        assert_equal 'payment_type', contribution.payment_type
      end

      should 'have the given organization_id' do
        contribution = send_create_contribution(organization_id: @organization.id)
        assert_equal @organization.id, contribution.organization_id
      end

      should 'have the given campaign_id' do
        contribution = send_create_contribution(campaign_id: @campaign.id)
        assert_equal @campaign.id, contribution.campaign_id
      end

      should 'have the given is_deleted' do
        contribution = send_create_contribution(is_deleted: false)
        assert_equal false, contribution.is_deleted
      end
    end

    context "update" do
      setup do
        @contribution = create(:contribution)
        @id = @contribution.contribution_id
      end

      should 'update invoice_code' do
        updated = send_update_contribution(invoice_code: 'invoice_code')
        assert_equal 'invoice_code', updated.invoice_code
      end

      should 'update raw_amount' do
        updated = send_update_contribution(raw_amount: 30)
        assert_equal 30, updated.raw_amount
      end

      should 'update recognition_amount' do
        updated = send_update_contribution(recognition_amount: 20)
        assert_equal 20, updated.recognition_amount
      end

      should 'update date' do
        d = @contribution.date + 1.day
        updated = send_update_contribution(date: d)
        assert_equal d, updated.date
      end

      should 'update stage' do
        updated = send_update_contribution(stage: 'stage')
        assert_equal 'stage', updated.stage
      end

      should 'update payment_type' do
        updated = send_update_contribution(payment_type: 'payment_type')
        assert_equal 'payment_type', updated.payment_type
      end

      should 'update organization_id' do
        create_organization_and_user
        updated = send_update_contribution(organization_id: @organization.id)
        assert_equal @organization.id, updated.organization_id
      end

      should 'update campaign_id' do
        updated = send_update_contribution(campaign_id: @campaign.id)
        assert_equal @campaign.id, updated.campaign_id
      end

    end

    should 'mark as deleted' do
      contribution = create(:contribution)
      updated = send_update_contribution(id: contribution.contribution_id, is_deleted: true)
      assert_equal true, updated.is_deleted
    end

    should 'mark as undeleted' do
      contribution = create(:contribution, is_deleted: true)
      updated = send_update_contribution(id: contribution.contribution_id, is_deleted: false)
      assert_equal false, updated.is_deleted
    end
  end

end
