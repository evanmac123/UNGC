atom_feed(:url => "http://localhost:3000/") do |feed|
  feed.title("UNGC COP Feed")
  #feed.updated(@cops.first.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
  feed.updated(@cops.first ? @cops.first.created_at : Time.now.utc)
  

  @cops.each do |cop|
    feed.entry(cop, :url => "http://localhost:3000/feeds/cops/") do |entry|
      entry.title(cop.organization.name + " - " + cop.title) rescue "TITLE RESCUE"
      entry.author do |author|
        author.name("Jamie")
      end
      entry.content("This is a placeholder for the content of the COP", :type => 'html') rescue "CONTENT RESCUE"
      #entry.updated(cop.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) rescue "UPDATED TIMESTAMP"
    end
  end
end