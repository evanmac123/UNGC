class Api::V1::ContributorsController < ApplicationController

  def show
    # all contributions.post for annual campaign with the matchign year

    contributors = contributors_for(year).map do |contribution|
      {
        id: contribution.organization_id,
        type: nil,
        name: contribution.organization.name,
        url: participant_url(contribution.organization),
        amount: bucket(contribution.amount),
      }
    end
    render json: contributors
  end

  private

  def bucket(amount)
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

  def year
    params.fetch(:year)
  end

  def contributors_for(year)
    Contribution.posted
    .joins(:campaign)
    .includes(:organization)
    .where("campaigns.name like ?", "#{year} Annual Contributions")
  end

end
