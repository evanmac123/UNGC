class Api::V1::ContributorsController < ApplicationController

  def show
    contributors = contributors_for(year).map do |contribution|
      {
        id: contribution.organization_id,
        type: contribution.campaign.kind,
        name: contribution.organization.name,
        url: participant_url(contribution.organization),
        amount: bucket(contribution),
      }
    end
    render json: contributors
  end

  private

  def bucket(contribution)
    amount = contribution.amount
    if contribution.campaign.lead?
      case
      when amount >= 65_000
        "$USD 65,000"
      when amount >= 50_000
        "$USD 50,000"
      when amount >= 35_000
        "$USD 35,000"
      when amount >= 20_000
        "$USD 20,000"
      when amount >= 10_000
        "$USD 10,000"
      else
        ""
      end
    else
      case
      when amount > 0 && amount < 500
        "< $USD 500"
      when amount < 5_000
        "$USD 500 - 4,999"
      when amount < 10_000
        "$USD 5000 - 9,999"
      when amount < 15_000
        "$USD 10,000 - 14,999"
      when amount >= 15000
        "$USD > 15,000"
      else
        ""
      end
    end
  end

  def year
    params.fetch(:year)
  end

  def contributors_for(year)
    annual_contribution = "#{year} Annual Contributions" #TODO bug with the pattern
    lead_contribution = "LEAD #{year}%"
    Contribution.posted
      .joins(:campaign)
      .includes(:campaign, :organization)
      .where("campaigns.name like ? or campaigns.name like ?", annual_contribution, lead_contribution)
  end

end
