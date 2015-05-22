class Components::Events
  include Enumerable

  def initialize(data)
    @data = data
  end

  def featured
    return unless @data[:events] && @data[:events][:featured_id]
    id = @data[:events][:featured_id]
    Event.approved.find_by(id: id)
  end

  def future
    Event.approved.where("starts_at >= ?", Date.today).order('starts_at asc')
  end

  def past
    Event.approved.where("starts_at < ?", Date.today).order('starts_at desc')
  end

  def each(&block)
    future.each do |e|
      block.call(e)
    end
  end
end

