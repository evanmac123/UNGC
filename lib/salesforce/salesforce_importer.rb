require 'csv'

class SalesforceImporter

  def self.import_from(path)
    new.import(path)
  end

  def create_campaign(params)
    campaign = Campaign.where(campaign_id: params['Id']).first_or_initialize
    campaign.update_attributes(
      name:       params['Name'],
      start_date: params['StartDate'],
      end_date:   params['EndDate'],
      is_deleted: params['IsDeleted'] == '1'
    )
    campaign
  end

  def create_contribution(params)
    # try to find the organization, if it's not valid, the finder will raise
    organization = Organization.find(params['organization_id'])

    contribution = Contribution.where(contribution_id: params['Id']).first_or_initialize
    contribution.update_attributes(
      campaign_id:          params['CampaignId'],
      organization_id:      organization.id,
      invoice_code:         params['Invoice_Code__c'],
      raw_amount:           params['Amount'],
      recognition_amount:   params['Recognition_Amount__c'],
      date:                 params['CloseDate'],
      stage:                params['StageName'],
      payment_type:         params['Payment_type__c'],
      is_deleted:           params['IsDeleted'] == '1',
    )
    contribution
  end

  def import(path)
    parser_params = { headers: true, encoding: 'ISO-8859-1' }
    account_organization_map = {}

    puts "mapping AccountID => Organization#id"
    CSV.foreach("#{path}/Account.csv", parser_params) do |row|
      account_id = row['Id']
      account_organization_map[account_id] = row['AccountNumber']
    end

    puts "importing Campaigns"
    Campaign.transaction do
      CSV.foreach("#{path}/Campaign.csv", parser_params) do |row|
        create_campaign(row.to_hash)
      end
    end

    puts "importing Contributions"

    CSV.foreach("#{path}/Opportunity.csv", parser_params) do |row|
      begin
        account_id = row['AccountId']
        organization_id = account_organization_map[account_id]

        params = row.to_hash.merge('organization_id' => organization_id)
        create_contribution(params)
      rescue ActiveRecord::RecordNotFound => e
        Rails.logger.error [e, organization_id]
        puts [e, organization_id]
      end
    end

  end

end
