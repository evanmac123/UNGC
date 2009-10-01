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
    files << fullname if name =~ /\.html$/ and !(name =~ /^search_participant/)
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

def subnav_from_left(doc)
  nav = doc/"#leftnav ul"
  subnav = doc/"#leftnav ul > li.sub"
  if subnav.any?
    currently_selected = doc/'#leftnav ul > li.selected'
    mid_nav = Navigation.find_by_label(currently_selected.inner_text.strip)
    raise currently_selected.inspect unless mid_nav
    subnav.map! do |sub|
      h = href_and_label(sub.at('a'))
      # new_label = h[:label].gsub('» ', '')
      h[:label] = h[:label][2,h[:label].size] # new_label
      array = mid_nav.href.split('/')
      array.pop
      h[:href] = "#{array.join('/')}#{h[:href]}"
      h[:parent_id] = mid_nav.id
      h
    end
  end
  subnav
end

def create_subnav(doc)
  subnav_from_left(doc).inject(0) do |counter, sub|
    existing = Navigation.find_by_href(sub[:href])
    unless existing
      Navigation.create sub.merge(:position => counter) 
      counter += 1
    end
  end
end

def escape_php(content)
  content = content.gsub(/<\?(php)?/, '&lt;?php ')
  content = content.gsub(/\?>/, ' ?&gt;')
end

def regular_page_content(doc)
  copy = (doc/'#content_inner .copy')
  if copy.first
    children = copy.first.children
  else
    puts " ** possible problems?"
    return ''
  end
  children.reject! { |c| c.class.to_s == 'Hpricot::BogusETag' }
  children.reject! { |c| c.to_html =~ /\A(<p>)?\s*(<\/p>)?\Z/ }
  content = children.map { |c| c.to_html }.join("\n")
  content = escape_php(content.strip)
  create_subnav(doc)
  if false
    path = []
    (doc/'#rightcontent .path p a').each do |elem|
      path << { elem.attributes['href'] => elem.inner_html }
    end
  end
  content
end

def local_network_sheet(doc)
  escape_php doc.to_html.strip
end

def href_and_label(link)
  href = "/" + link.get_attribute(:href)
  href << 'index.html' unless href =~ /\.html$/
  {
    :label => link.inner_text.strip,
    :href => href,
  }
end

def login_is_special 
  { :label => 'Login', :short => 'login', :href => '/login', :children => [] }
end

def attributes_for_element doc, elem
  link = elem.at('a')
  short = elem.get_attribute(:class)
  if short == 'login'
    login_is_special 
  else
    hash = href_and_label(link)
    hash[:short] = short
    hash[:children] = (doc/"div#nav > ul > li.#{short} > ul li a").map { |a| href_and_label(a) }
    hash
  end
end

def manually_adjust_shorts
  # these pages have specialized banners, but don't get picked up by the normal 'short' processor
  {
    'The CEO Water Mandate' => 'environment_ceo',
    'Caring for Climate'    => 'environment_c4c'
  }.each_pair do |label, short|
    nav = Navigation.find_by_label(label)
    if nav
      nav.update_attribute(:short, short)
    else
      puts "Problem with '#{label}'"
    end
  end
end

def parse_language_nav(root)
  filename = root + 'Languages/index.html'
  doc = Hpricot(open(filename))
  langs = doc/'#leftnav ul li a'
  top_lang = Navigation.create :href => "/#{filename - root}", :label => 'Languages', :top_nav => false
  langs.inject(0) do |counter, lang|
    h = href_and_label(lang)
    h[:href] = "/Languages#{h[:href]}"
    Navigation.create h.merge(:parent_id => top_lang.id, :position => counter)
    counter += 1
  end  
end

# Top nav elements read from home page
def parse_regular_nav(root)
  filename = root + 'index.html'
  doc = Hpricot(open(filename))
  (doc/'div#nav > ul > li').inject(0) do |i, elem|
    attrs = attributes_for_element doc, elem
    children = attrs.delete(:children)
    attrs[:position] = i
    parent = Navigation.create attrs
    children.inject(0) do |j, child|
      short = attrs[:label] == 'Issues' ? SHORTS[child[:label]] : ''
      Navigation.create child.merge(:parent_id => parent.id, :position => j, :short => short)
      j += 1
    end
    i += 1
  end
end

def parse_sitenav_nav(root)
  filename = root + 'WebsiteInfo/index.html'
  doc = Hpricot(open(filename))
  navs = doc/'#leftnav ul li a'
  top_site = Navigation.create :href => "/#{filename - root}", 
    :label => 'Website Information', 
    :short => 'websiteinfo',
    :top_nav => false
  navs.inject(0) do |counter, nav|
    h = href_and_label(nav)
    h[:href] = "/WebsiteInfo#{h[:href]}"
    Navigation.create h.merge(:parent_id => top_site.id, :position => counter)
    counter += 1
  end  
end

def read_and_write_content(root, filename)
  path = "/#{filename - root}".gsub('//', '/')
  content = Content.create :path => path, :content => read_content(root, filename)
  approve_first_version(content)
end

def approve_first_version(content)
  # Must have an approved version to be visible
  versions = content.versions(:reload)
  if versions.any?
    versions.first.approve!
  else
    raise "Oooops... no version for Content #{content.inspect}"
  end
end

def read_content(root, filename)
  doc = Hpricot(open(filename))
  if filename == (root + 'index.html')
    home_page_content(doc)
  elsif filename =~ /NetworksAroundTheWorld\/local_network_sheet/
    local_network_sheet(doc)
  elsif filename =~ /NewsAndEvents\/UNGC_bulletin\/contact_response\.html/
    local_network_sheet(doc)
  else
    regular_page_content(doc) # will also create sub-level leftnav
  end
end