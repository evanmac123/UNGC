class Api::V1::ContributorsController < ApplicationController

  # enable CORS for this endpoint
  # TODO properly support this in server config
  skip_before_filter :verify_authenticity_token

  before_filter :cors_preflight_check
  after_filter :cors_set_access_control_headers

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
    headers['Access-Control-Max-Age'] = "1728000"
  end

  def cors_preflight_check
    if request.method == 'OPTIONS'
      headers['Access-Control-Allow-Origin'] = '*'
      headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS'
      headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token'
      headers['Access-Control-Max-Age'] = '1728000'

      render :text => '', :content_type => 'text/plain'
    end
  end
  # end of CORS config

  def index
    contributors = ContributorsQuery.all
    payload = ContributorSerializer.as_json(contributors) do |participant|
      participant_url(participant)
    end
    render json: payload
  end

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
