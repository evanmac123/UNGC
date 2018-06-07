class ActionPlatform::PlatformsController < ApplicationController

  # ActionPlatforms are associated with the container in the sitemap by Taggings.
  # In order to tie a page in the sitemap with an Action Platform, edit the page
  # in the sitemap, and in the Taxonomy section, make sure the appropriate Action
  # Platform is selected.
  def show
    # Find the container match the path in the URL
    set_current_container_by_default_path

    # Lookup all the platforms the container is tagged with.
    platforms = platforms_tagged_by_container(current_container)

    # Find recent subscribers to those platforms
    query = ::ActionPlatform::RecentSubscribers.new(platforms: platforms, count: 5)
    participants = query.run

    # Combine the subscribers, platforms and sitemap/container content together for rendering
    @page = ::ActionPlatform::PlatformPage.new(current_container, current_payload_data,
      platforms, participants)

    # Render it with the appropriate layout
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
