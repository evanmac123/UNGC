class Redesign::Admin::Api::ContainersController < Redesign::Admin::ApiController
  def create
    STDOUT.puts(params.inspect)
  end
end
