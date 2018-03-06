class ActionPlatform::PlatformsController < ApplicationController

  def show
    set_current_container_by_default_path

    platforms = platforms_tagged_by_container(current_container)
    query = ::ActionPlatform::RecentSubscribers.new(platforms: platforms, count: 5)
    participants = query.run

    @page = ::ActionPlatform::PlatformPage.new(current_container, current_payload_data,
      platforms, participants)

    render "static/#{current_container.layout}"
  end

  private

  def slug
    params.fetch(:slug)
  end

  def platforms_tagged_by_container(container)
    container
      .taggings
      .with_action_platforms
      .includes(:action_platform)
      .map(&:action_platform)
  end

end
