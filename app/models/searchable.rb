# == Schema Information
#
# Table name: searchables
#
#  id              :integer(4)      not null, primary key
#  title           :string(255)
#  content         :text
#  url             :string(255)
#  document_type   :string(255)
#  last_indexed_at :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class SearchableHelper
  include ActionView::Helpers
  # include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  # include ActionView::Helpers::SanitizeHelper
  default_url_options[:host] = DEFAULTS[:url_host]
end

class Searchable < ActiveRecord::Base
  before_save :set_indexed_at
  
  define_index do
    indexes title
    indexes content
    has url, document_type, last_indexed_at
    set_property :delta => true
  end

  def set_indexed_at
    self.last_indexed_at = Time.now
  end

  def self.import(document_type, options)
    url = options.delete(:url)
    searchable = find_or_create_by_url(url)
    searchable.attributes = {:document_type => document_type}.merge(options || {})
    searchable.save
    searchable
  end
  
  def self.index_page(page)
    if page.approved? && !page.dynamic_content
      helper = SearchableHelper.new
      title = page.title
      content = helper.strip_tags page.content
      url = page.path
      unless title.blank? && content.blank?
        import 'Page', :url => url, :title => title, :content => content
      end
    end
  end

  def self.index_pages
    Page.approved.each { |page| index_page page }
  end
  
  def self.get_text_from_pdf(system_path_to_file)
    if File.exists?(system_path_to_file)
      `pdf2txt.py #{system_path_to_file}`
    else
      '' # TODO: or raise?
    end
  end
  
  def self.get_text_from_word(system_path_to_file)
    puts "I don't know this yet" # TODO
  end
  
  def self.index_pdf(system_path_to_file, public_path_to_file)
    title = 'PDF File'
    url   = public_path_to_file
    content = get_text_from_pdf(system_path_to_file)
    import 'PDF', :url => url, :title => title, :content => content
  end

  def self.index_event(event)
    helper = SearchableHelper.new
    title = event.title
    content = event.location + "\n" + 
      event.country.try(:name) + 
      helper.strip_tags(event.description)
    url = helper.instance_eval { event_path(event) }
    import 'Event', :url => url, :title => title, :content => content
  end

  def self.index_events
    Event.approved.each { |e| index_event e }
  end
  
  def self.index_headline(headline)
    helper = SearchableHelper.new
    title = headline.title
    content = headline.location + "\n" + 
      headline.country.try(:name) + 
      helper.strip_tags(headline.description)
    url = helper.instance_eval { headline_path(headline) }
    import 'Headline', :url => url, :title => title, :content => content
  end
  
  def self.index_headlines
    Headline.approved.each { |h| index_headline h }
  end

  def self.index_case_story(case_story)
    helper = SearchableHelper.new
    title = case_story.title
    if case_story.attachment_content_type == 'application/pdf'
      file_content = get_text_from_pdf(case_story.attachment.path)
    elsif case_story.attachment_content_type =~ /Word/
      file_content = get_text_from_word(case_story.attachment.path)
    end
    content = <<-EOF
      #{case_story.description}
      #{case_story.countries.map(&:name).join(' ')}
      #{file_content}
    EOF
    url = "/case_story/#{case_story.to_param}"
    import 'CaseStory', :url => url, :title => title, :content => content
  end

  def self.index_case_stories
    CaseStory.approved.each { |c| index_case_story c }
  end
  
end
