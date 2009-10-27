def load_replacements
  replacements = File.dirname(__FILE__) + '/../lib/content_replacements.yml'
  results = nil
  File.open( replacements ) { |yf| results = YAML::load( yf ) }
  results
end

def path_valid?(path)
  /\// =~ path
end

def replace_contents(path, new_content)
  puts "Replacing contents for '#{path}'"
  replace(path, new_content)
end

def replace(path, hash)
  begin
    content = Page.find_by_path path
    old_content = content.versions.first.content
    new_content = old_content.gsub(/\&lt;\?php[\s\w\W]+\?\&gt;/, hash['content'])
    new_version = content.new_version :content => new_content, :dynamic_content => true
    new_version.save!
    new_version.approve!
    puts "  done!"
    puts ''
  rescue Exception => e
    puts "Whooops! Some kind of #{e.inspect} while doing something with #{old_content.inspect}"
  end
end

def install_event_calendar
  content_for_archive = <<-EOF
  <h1><%= current_month %></h1>

  <% if this_months_events.any? %>
    <% for event in this_months_events do %>
      <h3><%= link_to event.title, event_path(event) %></h3>
      <div><%= event.starts_on %> - <%= event.ends_on %></div>
      <%= event.description %>
    <% end %>
  <% else %>
    <p>No events currently planned for <%= current_month %>.</p>
  <% end %>

  <%= links_to_other_months %>
  EOF

  puts "Installing new dynamic event calendar"
  old = Page.find_by_path '/NewsAndEvents/2009_events.html'
  options = {
    :path            => '/NewsAndEvents/Upcoming_Events.html', 
    :content         => content_for_archive, 
    :position        => old.position,
    :dynamic_content => true
  }
  clone = old.new_version(options)
  clone.approve!
  old.update_attributes :display_in_navigation => false
  puts "  done!\n"
end

def rewrite_event_archives
  puts "Updating links to old event archives"
  archive = Page.find_by_path '/NewsAndEvents/news_archives/event_archive.html'
  replacing = %r{<a href="../upcoming_events.html" target="_self" title="2008 Event Calendar">2008 Event Calendar</a>}
  new_content = <<-EOF
  <li>
    <div>
      <a href="../2009_events.html" target="_self" title="2009 Event Calendar">2009 Event Calendar</a>
    </div>
  </li>
  <li>
    <div>
      <a href="../2008_events.html" target="_self" title="2008 Event Calendar">2008 Event Calendar</a>
  EOF
  # the closing tags are not in the replacing expression
  archive.content = archive.content.gsub replacing, new_content
  archive.save!
  puts "  done!\n"
end

def archive_latest_headlines
  content_for_future = <<-EOF
  <h1>Recent Headlines</h1>

  <% if headlines.any? %>
    <ul>
    <% for headline in headlines do %>
      <li>(<%= headline.published_on %>) <%= link_to headline.title, headline %></li>
    <% end %>
    </ul>
  <% else %>
    <p>There have been no recent headlines. Feel free to browse the archives.</p>
  <% end %>
  EOF

  puts "Making an archive page from 2009 headlines"
  oh_niner = Page.approved.find_by_path '/NewsAndEvents/index.html'
  future = Page.new oh_niner.attributes.merge(:dynamic_content => true)

  oh_niner.path = '/NewsAndEvents/news_archives/news_2009.html'
  oh_niner.content = oh_niner.content.gsub(/<h1>Recent Headlines<\/h1>/, '<h1>News Archive 2009</h1>')
  oh_niner.position = nil
  oh_niner.display_in_navigation = false
  oh_niner.save
  puts "  done!"
  
  puts "Making a dynamic headline page"
  future.content = content_for_future
  future.save
  puts "  done!"
end

def rewrite_network_dropdown
  puts "Rewriting network dropdown"
  page = Page.find_by_path '/NetworksAroundTheWorld/index.html'
  content = page.content
  gulf = [
    %q{<option value="/NetworksAroundTheWorld/display.html?id=AE">Gulf States</option>},
    '<option value="/NetworksAroundTheWorld/display.html?id=GS">Gulf States</option>'
  ]
  nord = [
    %q{<option value="/NetworksAroundTheWorld/display.html?id=DK">Nordic Countries</option>},
    '<option value="/NetworksAroundTheWorld/display.html?id=NC">Nordic Countries</option>'
  ]
  [gulf, nord].each do |search, replace|
    content = content.gsub(search, replace)
  end
  page.update_attribute :content, content
  puts " done!"
  puts "\n"
end

def rewrite_news_headlines
  puts "Adding 2009 archive to Archive page"
  archive = Page.find_by_path '/NewsAndEvents/news_archives/index.html'
  replacing = %r{<ul>\s+<li>\s+<a target="_self" href="news_2008.html">2008</a>\s+</li>}
  new_content = <<-EOF
  <ul>
    <% for year in news_archive_years do %>
      <% if year %><li><%= link_to year, headline_year_path(:year => year) %></li><% end %>
    <% end %>
    <li>
      <a target="_self" href="news_2009.html">2009</a>
    </li>
    <li>
      <a target="_self" href="news_2008.html">2008</a>
    </li>
  EOF
  # the closing tags are not in the replacing expression
  archive.content = archive.content.gsub replacing, new_content
  archive.dynamic_content = true
  archive.save!
  puts "  done!\n"  
end

def rewrite_homepage
  puts "Doing something with homepage"
  home = Page.find_by_path '/index.html'
  doc = Hpricot(home.content)
  news_links = doc/'.news_list .news_item'
  # add dynamic content at top
  dynamic = <<-EOF
    <% counter = 0 %>
    <% for headline in headlines[0,9] do %>
      <div class='news_item <%= cycle('blue', '') %>'>
        <div class='date'><%= mm_dd_yyyy headline.published_on %></div>
        <div class='title'><%= link_to headline.title, headline %></div>
        <% counter += 1 %>
      </div>
    <% end %>
    <%# FIXME: Remove these lines once there are nine or more 'dynamic' headlines %>
  EOF
  # add counter check and counter++ to each element
  rebuilt = [dynamic] + news_links.map do |e|
    inner = e.inner_html  
    replacement = <<-EOF
      <% if counter < 9 %>
        <div class='news_item <%= cycle('blue', '') %>'>
          <% counter += 1 %>
          #{inner}
        </div>
      <% end %>
    EOF
  end
  doc.at('.news_list').inner_html = rebuilt.join("\n\n")
  content = doc.to_html
  nv = home.new_version :dynamic_content => true, :content => content
  nv.approve!
  puts " done!"
end