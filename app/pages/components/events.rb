class Components::Events
  include Enumerable

  attr_reader :tier

  def initialize(data, tier: nil)
    @data = data
    @tier = tier
  end

  def featured
    return unless @data[:events] && @data[:events][:featured_id]
    id = @data[:events][:featured_id]
    Event.approved.find_by(id: id)
  end

  def future
    future = scoped.where("starts_at >= ?", Date.today).order('starts_at asc')
    future = featured ? future[0..5] : future[0..8]
    future.each_slice(3).to_a
  end

  def past
    scoped.where("starts_at < ?", Date.today).order('starts_at desc')
  end

  def each(&block)
    future.each do |e|
      block.call(e)
    end
  end

  private

  def scoped
    scoped = Event.approved
    case tier
    when :tier1
      scoped = scoped.tier1
    end
    scoped
  end
end

