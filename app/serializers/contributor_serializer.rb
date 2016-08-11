class ContributorSerializer < ApplicationSerializer

  def attributes
    {
      id: contribution.organization_id,
      year: year,
      type: contributor_type,
      name: contribution.organization.name,
      url: participant_url(contribution.organization),
      amount: bucket,
    }
  end

  alias_method :contribution, :object

  private

  def year
    contribution.campaign.year
  end

  def amount
    contribution.amount
  end

  def contributor_type
    if contribution.campaign.kind == "lead"
      "LEAD"
    else
      "Annual"
    end
  end

  def bucket
    if contribution.campaign.lead?
      lead_bucket(amount)
    else
      annual_bucket(amount)
    end
  end

  def lead_bucket(amount)
    case
    when amount >= 65_000
      "USD 65,000"
    when amount >= 50_000
      "USD 50,000"
    when amount >= 35_000
      "USD 35,000"
    when amount >= 20_000
      "USD 20,000"
    when amount >= 10_000
      "USD 10,000"
    else
      "In Kind Staff Support"
    end
  end

  def annual_bucket(amount)
    case
    when amount > 0 && amount < 500
      "< USD 500"
    when amount < 5_000
      "USD 500 - 4,999"
    when amount < 10_000
      "USD 5000 - 9,999"
    when amount < 15_000
      "USD 10,000 - 14,999"
    when amount >= 15000
      "USD > 15,000"
    else
      ""
    end
  end
end
