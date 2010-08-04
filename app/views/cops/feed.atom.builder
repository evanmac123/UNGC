atom_feed(:url => "http://localhost:3000/") do |feed|
  feed.title("UNGC Communications on Progress")
  #feed.updated(@cops.first.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
  feed.updated(@communication_on_progresses.first ? @communication_on_progresses.first.created_at : Time.now.utc)
  

  @communication_on_progresses.each do |cop|
    @communication_on_progress = cop
    feed.entry(cop, :url => "/COPs/detail/#{cop.id}") do |entry|
      entry.title(cop.organization.name + " - " + cop.title) rescue "TITLE RESCUE"
      entry.author do |author|
        author.name(cop.organization.name.to_s)
      end
      #entry.content(render(:controller => :organizations, "))
      entry.content(render(:partial => '/shared/cops/feed.html.haml', :format => :html), :type => 'html')
      entry.updated(cop.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) rescue Time.now
    end
  end
end