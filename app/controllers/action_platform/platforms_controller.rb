class ActionPlatform::PlatformsController < ApplicationController

  def show
    platform = ActionPlatform::Platform.find(params.fetch(:id))
    @page = ActionPlatform::PlatformPage.new(platform)
  end

end
