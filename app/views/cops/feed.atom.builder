atom_feed(:url => "http://#{request.host}/feeds/cops/") do |feed|
  feed.title("United Nations Global Compact - Communication on Progress")
  feed.updated(@cops_for_feed.first ? @cops_for_feed.first.created_at : Time.now.utc)

  @cops_for_feed.each do |cop|
    feed.entry(cop, :url => cop_detail_url(cop)) do |entry|
      entry.title(cop.organization.name + " - " + cop.title) rescue "United Nations Global Compact - Communication on Progress"
      entry.author do |author|
        author.name(cop.organization.name.to_s)
      end
      content = with_format 'html' do
        render :partial => '/shared/cops/feed', :locals => { :communication_on_progress => cop, :feed => true }
      end
      entry.content(content, :type => 'html')
    end
  end
end
