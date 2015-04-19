class Components::Participants
  attr_accessor :data

  def initialize(data)
    self.data = data
  end

  def data
    participants.map do |p|
      {
        name: p.name,
        sector: p.sector.name,
        country: p.country.name,
        url: 'participant url'
      }
    end
  end

  private

  def participants
    return [] unless initiative_id
    initiative.signatories.includes(:sector, :country).limit(5)
  end


  def initiative
    Initiative.find(initiative_id)
  end

  def initiative_id
    @data[:initiative][:initiative_id] if @data[:initiative]
  end
end
