class Components::News
  include Enumerable

  def initialize(data)
    @data = data
  end

  def each(&block)
    data.each do |d|
      block.call(d)
    end
  end

  def data
    headlines.map do |h|
      {
        item: h,
        title: h.title,
        date: h.published_on,
        location: h.full_location,
        excerpt: h.description,
        thumbnail: nil
      }
    end
  end

  private

  def headlines
    Headline.order('published_on desc').limit(6)
  end
end
