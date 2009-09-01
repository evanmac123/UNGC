def Dir.stuff(path)
  not_stuff = ['.', '..', '.DS_Store']
  entries(path) - not_stuff
end

def get_files_from(path, files=[])
  Dir.stuff(path).each do |name|
    fullname = File.join(path, name)
    files << fullname if name =~ /\.html$/ unless name =~ /^search_participant/
    if File.directory?(fullname)
      files += get_files_from(fullname)
    end
  end
  return files
end

def home_page_content doc
  content = (doc/'#content_home')
  content = (content.first || content).inner_html.strip
end

def regular_page_content doc
  content = (doc/'#content_inner .copy p')
  content = (content.first || content).inner_html.strip
  if false
    path = []
    (doc/'#rightcontent .path p a').each do |elem|
      path << { elem.attributes['href'] => elem.inner_html }
    end
  end
  content
end

def href_and_label(link)
  href = "/" + link.get_attribute(:href)
  href << 'index.html' unless href =~ /\.html$/
  {
    :label => link.inner_text,
    :href => href,
  }
end

def login_is_special 
  { :label => 'Login', :short => 'login', :href => '/login', :children => [] }
end

def attributes_for_element elem
  link = elem.at('a')
  short = elem.get_attribute(:class)
  if short == 'login'
    login_is_special 
  else
    hash = href_and_label(link)
    hash[:short] = short
    hash[:children] = ($doc/"div#nav > ul > li.#{short} > ul li a").map { |a| href_and_label(a) }
    hash
  end
end
