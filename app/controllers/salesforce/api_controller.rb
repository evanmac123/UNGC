class Salesforce::ApiController < ApplicationController
  before_filter :authorize_token
  skip_before_filter :verify_authenticity_token

  def sync
    status = if SalesforceSync.sync job_params[:_json]
      :ok
    else
      :unprocessable_entity
    end

    render json: {}, status: status
  end

  protected

  def job_params
    params.require(:api).permit(
      :_json => [
        :id,
        :type,
        :name,
        :date,
        :start_date,
        :end_date,
        :stage,
        :organization_id,
        :campaign_id,
        :is_deleted,
        :payment_type,
        :invoice_code,
        :raw_amount,
        :recognition_amount,
        :is_private
      ]
    )
  end

  def authorize_token
    authenticate_or_request_with_http_token do |token, options|
      # TODO move this token elsewhere.
      token == '16d7d6089b8fe0c5e19bfe10bb156832'
    end
  end

end
