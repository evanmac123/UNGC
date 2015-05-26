class Components::News
  include Enumerable

  attr_reader :news_type
  def initialize(data, news_type: nil)
    @data = data
    @news_type = news_type
  end

  def each(&block)
    data.each do |d|
      block.call(d)
    end
  end

  def data
    news = scoped.map do |h|
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

  def scoped
    scoped = Headline
    case news_type
    when :announcement
      scoped = scoped.announcement
    end
    scoped.order('published_on desc').limit(9)
  end
end
