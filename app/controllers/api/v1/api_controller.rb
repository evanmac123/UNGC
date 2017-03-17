class Api::V1::ApiController < ApplicationController

  protected

  def current_resource_owner
    Contact.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

end
