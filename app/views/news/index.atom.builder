atom_feed(:url => "http://#{request.host}/feeds/news/") do |feed|

  feed.title("United Nations Global Compact - Latest News")
  feed.updated(@headlines.first.published_on)

  for headline in @headlines
    feed.entry(headline, :url => headline_url(headline)) do |entry|
      entry.title(strip_tags(headline.title))
      entry.content(headline.teaser, :type => 'html')
      entry.author do |author|
        author.name("United Nations Global Compact")
      end
    end
  end
end
