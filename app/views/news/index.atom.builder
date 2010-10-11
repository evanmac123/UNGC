atom_feed :root_url => url_for('/NewsAndEvents/'), :schema_date => "2008-09-07" do |feed|
  feed.title("United Nations Global Compact - Latest News")
  # feed.icon(@author.favicon) if @author.favicon
  feed.updated((@headlines.first.published_on))

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
