atom_feed(:url => "http://#{request.host}/feeds/cops/") do |feed|
  feed.title("United Nations Global Compact - Communication on Progress")
  feed.updated(@cops_for_feed.first ? @cops_for_feed.first.created_at : Time.now.utc)

  @cops_for_feed.each do |cop|
    feed.entry(cop, :url => cop_link(cop)) do |entry|
      entry.title(cop.organization.name + " - " + cop.title) rescue "United Nations Global Compact - Communication on Progress"
      entry.author do |author|
        author.name(cop.organization.name.to_s)
      end
      entry.content(render(:partial => '/shared/cops/feed.html.haml', :locals => { :communication_on_progress => cop, :feed => true }, :format => :html), :type => 'html')
    end
  end
end

def content_for_cop(cop)
  
end