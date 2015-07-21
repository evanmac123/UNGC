require 'test_helper'

class NewsFeedTest < ActionDispatch::IntegrationTest

  setup do
    create_container path: '/news/press-releases'
    Headline.stubs(search: [headline])
  end

  test 'stuff' do
    visit redesign_feeds_news_path

    feed = Nokogiri::XML(page.body)
    link = feed.css("entry link[rel=alternate]").first

    assert_not_nil link, 'no headline found'
    assert_match headline.to_param, link['href']
  end

  private

  def headline
    @headline ||= create_headline
  end

end
