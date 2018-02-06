class Components::Events
  include Enumerable

  attr_reader :tier

  def initialize(data, tier: nil)
    @data = data
    @tier = tier
  end

  def featured
    return unless featured_id
    event = Event.approved.find_by(id: featured_id)
    Event::Featured.new(event)
  end

  def future
    future = scoped.where(starts_at: Date.current..20.years.from_now)
    future = future.where.not(id: featured_id) if featured_id
    future = future.order(:starts_at, :id)
    future = featured ? future[0..5] : future[0..8]

    future.each_slice(3).to_a
  end

  def past
    scoped.where(starts_at: 20.years_ago..1.day.ago).order(starts_at: :desc, id: :asc)
  end

  def each(&block)
    future.each do |e|
      block.call(e)
    end
  end

  private

  def featured_id
    @data[:events] && @data[:events][:featured_id]
  end

  def scoped
    scoped = Event.approved.includes(:country)
    case tier
    when :tier1
      scoped = scoped.tier1
    end
    scoped
  end
end
