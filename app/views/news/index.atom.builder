atom_feed :root_url=>url_for('/news'), :schema_date => "2008-09-07" do |feed|
  feed.title("News Headlines from UNGC")
  # feed.icon(@author.favicon) if @author.favicon
  feed.updated((@headlines.first.updated_at))

  for headline in @headlines
    feed.entry(headline, :url=>headline_url(headline)) do |entry|
      entry.title(strip_tags(headline.title))
      entry.content(headline.description, :type => 'html')
      # entry.author do |author|
      #   author.name(post.author.full_name)
      # end
    end
  end
end
