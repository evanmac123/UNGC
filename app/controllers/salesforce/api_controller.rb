class Salesforce::ApiController < ApplicationController
  before_filter :authorize_token
  skip_before_filter :verify_authenticity_token

  def sync
    status = if SalesforceSync.sync job_params
      :ok
    else
      :unprocessable_entity
    end

    render json: {}, status: status
  end

  protected

  def job_params
    params[:api]['_json']
  end

  def authorize_token
    authenticate_or_request_with_http_token do |token, options|
      # TODO move this token elsewhere.
      token == '16d7d6089b8fe0c5e19bfe10bb156832'
    end
  end

end
