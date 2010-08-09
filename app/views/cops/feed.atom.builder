atom_feed(:url => "/feeds/cops") do |feed|
  feed.title("UNGC Communications on Progress")
  feed.updated(@cops_for_feed.first ? @cops_for_feed.first.created_at : Time.now.utc)

  @cops_for_feed.each do |cop|
    feed.entry(cop, :url => "/COPs/detail/#{cop.id}") do |entry|
      entry.title(cop.organization.name + " - " + cop.title) rescue "Title"
      entry.author do |author|
        author.name(cop.organization.name.to_s)
      end
      entry.content(render(:partial => '/shared/cops/feed.html.haml', :locals => { :communication_on_progress => cop, :feed => true }, :format => :html), :type => 'html')
      entry.updated(cop.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) rescue Time.now
    end
  end
end

def content_for_cop(cop)
  
end