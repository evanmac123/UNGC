atom_feed do |feed|
  feed.title("UNGC COP Feed")
  
  if @cops.empty?
    #feed.updated(Time.now.strftime("%Y-%m-%dT%H:%M:%SZ"))
  else
    feed.updated(@cops.first.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ"))
  end
  
  @cops.each do |cop|
    next if cop.updated_at.blank?
    feed.entry(cop) do |entry|
      entry.title(cop.organization.name)
      entry.content("Content: " + cop.related_document, :type => 'html')
      entry.updated(cop.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ")) # needed to work with Google Reader.
    end
  end
  
end