class Components::Participants
  attr_accessor :data
  include Enumerable
  include Rails.application.routes.url_helpers

  def initialize(data)
    self.data = data
  end

  def data
    participants.map do |p|
      {
        name: p.name,
        sector: p.sector.name,
        country: p.country.name,
        participant: p
      }
    end
  end

  def who_is_involved_path
    participant_search_path(search: { initiatives: [initiative_id] })
  end

  def initiative_id
    @data[:initiative][:initiative_id] if @data[:initiative]
  end

  def each(&block)
    data.each do |p|
      block.call(p)
    end
  end

  def empty?
    participants.empty?
  end

  private

  def participants
    return [] unless initiative_id
    initiative.signatories.includes(:sector, :country).limit(5).order('signings.added_on desc')
  end


  def initiative
    Initiative.find(initiative_id)
  end
end
