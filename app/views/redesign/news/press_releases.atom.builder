atom_feed(:url => "http://#{request.host}/feeds/news/") do |feed|

  feed.title("United Nations Global Compact - Latest News")
  feed.updated(@page.last_updated_at)
  for headline in @page.results
    feed.entry(headline, :url => redesign_news_url(headline)) do |entry|
      entry.title(strip_tags(headline.title))
      entry.content(headline.teaser, :type => 'html')
      entry.author do |author|
        author.name("United Nations Global Compact")
      end
    end
  end
end
