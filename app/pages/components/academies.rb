class Components::Academies
  include Enumerable

  attr_reader :data

  def initialize(data)
    @data = data
  end

  def events
    scoped.where(starts_at: Date.current..20.years.from_now)
      .order(:starts_at, :id)
      .each_slice(3)
      .to_a
  end

  def each(&block)
    events.each do |e|
      block.call(e)
    end
  end

  private

  def scoped
    Event.approved
      .includes(:country)
      .where(is_academy: true)
  end

end
