class ActionPlatform::PlatformPage < ActionDetailPage

  def initialize(container, payload, platforms, participants)
    super(container, payload)
    @platforms = platforms
    @participants = participants
  end

  def participants
    participants = @participants.map do |p|
      {
        name: p.name,
        sector: p.sector_name,
        country: p.country_name,
        participant: p,
      }
    end
    Participants.new(participants, @platforms)
  end

  private

  # Conform to the same interface as Components::Participants
  # so we can re-use it's template
  class Participants
    include Rails.application.routes.url_helpers

    attr_reader :participants

    delegate :empty?, :each, to: :participants

    def initialize(participants, platforms)
      @participants = participants
      @platforms = platforms
    end

    def who_is_involved_path
      participant_search_path(search: {
        action_platforms: @platforms.map(&:id)
      })
    end

  end
end
