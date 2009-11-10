# Little helper method -- like try, but can use a block
class Object
  def no_nil(&block)
    yield(self)
  rescue NoMethodError
    nil
  end
end

# Monkey-patch Hpricot to force file encoding to utf-8
module Hpricot
  # XML unescape
  def self.uxs(str)
    str.force_encoding("UTF-8")
    str.to_s.
        gsub(/\&(\w+);/) { [NamedCharacters[$1] || ??].pack("U*") }.
        gsub(/\&\#(\d+);/) { [$1.to_i].pack("U*") }
  end
end

def Dir.stuff(path)
  not_stuff = ['.', '..', '.DS_Store']
  entries(path) - not_stuff
end

def get_files_from(path, files=[])
  Dir.stuff(path).each do |name|
    fullname = File.join(path, name)
    files << fullname if name =~ /\.html$/ # and !(name =~ /^search_participant/)
    if File.directory?(fullname)
      files += get_files_from(fullname)
    end
  end
  return files
end

def home_page_content(doc)
  content = (doc/'#content_home')
  content = (content.first || content).inner_html.strip
end

def subnav_from_left(doc, filename, root)
  nav = doc/"#leftnav ul"
  subnav = doc/"#leftnav ul > li.sub"
  if subnav.any?
    currently_selected = doc/'#leftnav ul > li.selected'
    # These links are often relative, like '../index.html' - so we'd like to match
    # the text (title), except that not all titles are unique. So, we start with
    # pages matching the title, and - when necessary - narrow to pages matching the
    # filename's base path.
    possible = Page.find_all_by_title(currently_selected.inner_text.strip)
    if possible.size > 1
      likely = possible.detect { |p| p.path.match((filename - root).split('/').first) }
      if likely
        mid_nav = likely
      else
        breakpoint
      end
    else
      mid_nav = possible.first
    end
    subnav = subnav.map do |sub|
      h = href_and_label(sub.at('a'))
      # new_label = h[:title].gsub('» ', '')
      h[:title] = h[:title][2,h[:title].size] # new_label
      array = mid_nav.path.split('/')
      array.pop
      h[:path] = "#{array.join('/')}#{h[:path]}"
      h[:parent_id] = mid_nav.id
      h
    end
  end
  subnav
end

def possibly_move(path)
  return path unless MOVED_PAGES[path]
  MOVED_PAGES[path]
end

def find_parent_for(path)
  debug = false # path =~ /Meetings/i
  puts " Trying to find parent for #{path}" if debug
  array = path.split('/')
  times_to_try = array.size - 2 # not the first empty element, nor the first "top-level" folder
  times_to_try.times do
    array.pop
    try_this_path = array.join('/') + '/index.html'
    puts "   trying '#{try_this_path}'" if debug
    possible = Page.find(:first, :conditions => {
      :display_in_navigation => true, 
      :path => try_this_path}, :include => :children) # 
    return possible if possible
  end
  nil
end

def create_subnav(doc, filename, root)
  subnav_from_left(doc, filename, root).inject(0) do |counter, sub|
    page = Page.find_by_path(possibly_move(sub[:path])) || Page.new(possibly_move(:path => sub[:path]))
    page.title = sub[:title] # Prefer title from link text
    page.parent_id = sub[:parent_id] if page.parent_id.blank?
    page.display_in_navigation = true
    page.position = counter
    page.save
    counter += 1
  end
end

def escape_php(content)
  content = content.gsub(/<\?(php)?/, '&lt;?php ')
  content = content.gsub(/\?>/, ' ?&gt;')
end

def get_headline(doc)
  if headlines = (doc/'h1') and headlines.any?
    headline = headlines.first.inner_text.try(:strip)
    headline.gsub!(/\s+/, ' ')
  end
end

def regular_page_content(doc, filename, root, title=nil)
  title = get_headline(doc)
  copy = (doc/'#content_inner .copy')
  if copy.first
    children = copy.first.children
  else
    puts " ** possible problems?"
    return ''
  end
  children.reject! { |c| c.class.to_s == 'Hpricot::BogusETag' }
  children.reject! { |c| c.to_html =~ /\A(<p>)?\s*(<\/p>)?\Z/ }
  content = children.map { |c| c.to_html.force_encoding('UTF-8') }.join("\n")
  content = escape_php(content.strip)
  create_subnav(doc, filename, root)
  if false
    path = []
    (doc/'#rightcontent .path p a').each do |elem|
      path << { elem.attributes['href'] => elem.inner_html }
    end
  end
  {title: title, content: content}
end

def unfiltered_content(doc)
  escape_php doc.to_html.strip
end

def local_network_sheet(doc)
  title = get_headline(doc)
  content = escape_php doc.to_html.strip
  content << "\n\n&lt;?php put/local/network/info/here.php ?&gt;"
  {title: title, content: content}
end

def href_and_label(link)
  href = "/" + link.get_attribute(:href)
  href << 'index.html' unless href =~ /\.html$/
  {
    :title => link.inner_text.strip,
    :path => possibly_move(href),
  }
end

def attributes_for_element doc, elem
  link = elem.at('a')
  short = elem.get_attribute(:class)
  if short == 'login' # login is special
    {}
  else
    hash = href_and_label(link)
    hash[:html_code] = short
    hash[:children] = (doc/"div#nav > ul > li.#{short} > ul li a").map { |a| href_and_label(a) }
    hash
  end
end

def manually_adjust_shorts
  # these pages have specialized banners, but don't get picked up by the normal 'short' processor
  special = {
    'The CEO Water Mandate' => 'environment_ceo',
    'Caring for Climate'    => 'environment_c4c'
  }
  special.each_pair do |label, short|
    nav = Page.find_by_title(label)
    if nav
      nav.update_attribute(:html_code, short)
    else
      puts "Problem with '#{label}'"
    end
  end
end

def parse_language_nav(root)
  filename = root + 'Languages/index.html'
  doc = Hpricot(open(filename))
  langs = doc/'#leftnav ul li a'
  group = PageGroup.create :name => 'Non-English Resources', :html_code => false, :display_in_navigation => false
  top_lang = Page.create :path => "/#{filename - root}", :top_level => true, :title => 'Languages', :display_in_navigation => false, :group_id => group.id
  langs.inject(0) do |counter, lang|
    h = href_and_label(lang)
    h[:path] = "/Languages#{h[:path]}"
    Page.create h.merge(:parent_id => nil, :top_level => true, :group_id => group.id, :position => counter, :display_in_navigation => true)
    counter += 1
  end  
end

# Top nav elements read from home page
def parse_regular_nav(root)
  filename = root + 'index.html'
  doc = Hpricot(open(filename))
  (doc/'div#nav > ul > li').inject(0) do |i, elem|
    attrs = attributes_for_element doc, elem
    next unless attrs.any?

    children = attrs.delete(:children)
    attrs[:position] = i
    group = PageGroup.create :name => attrs[:title], :html_code => attrs[:html_code], :display_in_navigation => true
    children.inject(0) do |j, child|
      short = attrs[:title] == 'Issues' ? CODES[child[:title]] : nil # Special html_codes all comes from issues
      Page.create child.merge(:parent_id => nil, :top_level => true, :position => j, :html_code => short, :group_id => group.id, :display_in_navigation => true)
      j += 1
    end
    i += 1
  end
end

def parse_sitenav_nav(root)
  filename = root + 'WebsiteInfo/index.html'
  doc = Hpricot(open(filename))
  navs = doc/'#leftnav ul li a'
  group = PageGroup.find_by_html_code('website') || PageGroup.create(:name => 'Website Information', :html_code => 'website', :display_in_navigation => false)
  path = possibly_move("/#{filename - root}")
  info = Page.find_by_path(path) || Page.create(:path => path, :group_id => group.id)
  info.update_attributes :title => 'Website Information', 
    :html_code => 'websiteinfo',
    :top_level => true,
    :display_in_navigation => false
  navs.inject(0) do |counter, nav|
    h = href_and_label(nav)
    h[:path] = possibly_move "/WebsiteInfo#{h[:path]}"
    h.merge!(:parent_id => nil, :top_level => true, :group_id => group.id, :position => counter, :display_in_navigation => true)
    if page = Page.find_by_path(h[:path])
      page.update_attributes(h)
    else
      Page.create h
    end
    counter += 1
  end  
end

def read_and_write_content(root, filename)
  path = "/#{filename - root}".gsub('//', '/')
  # puts " looking for #{path.inspect}"
  options = read_content(root, filename) || {}
  path = possibly_move(path)
  # puts " ** Looking for #{path}" if path =~ /meetings/i
  page = Page.find_by_path(path) || Page.new(:path => path)
  begin
    page.title = options[:title] if page.title.blank? unless options[:title].blank? # Prefer the title that comes from the link text
    page.content = options[:content] unless options[:content].blank?
    update_after = page unless page.parent_id
    result = page.save
    approve_first_version(page)
  rescue Exception => e
    puts " ** Options: #{options.inspect} but #{e.inspect}"
  end
  return update_after
end

def approve_first_version(content)
  debug = false # content.path =~ /(search_participant|Seal_the_Deal)/
  puts "Trying to approve #{content.path}" if debug
  # Must have an approved version to be visible
  versions = content.versions
  if versions.any? && approve_me = versions.first
    approve_me.approve! if approve_me.can_approve?
  else
    raise "Oooops... no version for Page #{content.inspect}"
  end
end

def read_content(root, filename)
  doc = Hpricot(open(filename))
  if filename == (root + 'index.html')
    {:content => home_page_content(doc)}
  elsif filename =~ /NetworksAroundTheWorld\/Newsletter/ || filename =~ /WebsiteInfo\/site_map\.html/
    {} # FIXME
  elsif filename =~ /NetworksAroundTheWorld\/local_network_sheet/
    local_network_sheet(doc)
  elsif filename =~ /NewsAndEvents\/UNGC_bulletin\/contact_response\.html/
    {:content => unfiltered_content(doc)}
  else
    regular_page_content(doc, filename, root) # will also create sub-level leftnav
  end
end

def update_navigation_info(pages)
  pages.each do |page|
    next if page.top_level?
    possible = find_parent_for(page.path)
    if possible and possible != page # this can happen as we update old records sometimes
      page.parent = possible
      page.save
    end
  end
  
  parent_ids = Page.find(:all, :conditions => ["parent_id is not null"]).map(&:parent_id).uniq.compact
  parents = Page.find parent_ids
  parents.each do |parent|
    parent.children.each do |child|
      child.update_attribute :group_id, parent.group_id || parent.parent.group_id
    end
  end
end
