require 'test_helper'

class NewsFeedTest < ActionDispatch::IntegrationTest

  setup do
    create(:container, path: '/news/press-releases')
    @headline = create(:headline)
    Headline.stubs(search: [@headline])
  end

  test 'the news feed' do
    visit feeds_news_path

    feed = Nokogiri::XML(page.body)
    link = feed.css("entry link[rel=alternate]").first

    assert_not_nil link, 'no headline found'
    assert_match @headline.to_param, link['href']
  end

end
