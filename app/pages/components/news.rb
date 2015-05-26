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
    news = headlines.map do |h|
      {
        item: h,
        title: h.title,
        date: h.published_on,
        location: h.full_location,
        excerpt: h.description,
        thumbnail: nil
      }
    end

    news.each_slice(3).to_a
  end

  private

  def headlines
    Headline.order('published_on desc').limit(9)
  end
end
