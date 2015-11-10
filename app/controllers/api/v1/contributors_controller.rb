class Api::V1::ContributorsController < ApplicationController

  def show
    contributors = ContributorsQuery.contributors_for(year)
    payload = ContributorSerializer.as_json(contributors) do |participant|
      participant_url(participant)
    end
    render json: payload
  end

  def year
    params.fetch(:year)
  end

end
