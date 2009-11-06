# == Schema Information
#
# Table name: searchables
#
#  id                :integer(4)      not null, primary key
#  title             :string(255)
#  content           :text
#  url               :string(255)
#  document_type     :string(255)
#  last_indexed_at   :datetime
#  created_at        :datetime
#  updated_at        :datetime
#  delta             :boolean(1)      default(TRUE), not null
#  object_created_at :datetime
#  object_updated_at :datetime
#

class SearchableHelper
  include ActionView::Helpers
  # include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  # include ActionView::Helpers::SanitizeHelper
  default_url_options[:host] = DEFAULTS[:url_host]
end

require 'ostruct'

class Searchable < ActiveRecord::Base
  before_create :set_object_created_at
  before_save   :set_object_updated_at
  before_save   :set_indexed_at
  attr_accessor :object
  
  define_index do
    indexes title
    indexes content
    has document_type, :facet => true
    has url, last_indexed_at
    set_property :delta => true # TODO: Switch this to :delayed once we have DJ working
  end

  def self.faceted_search(document_type, keyword, options={})
    options.merge!({with: {document_type_facet: document_type.to_crc32 } })
    search keyword, options
  end

  def set_indexed_at
    self.last_indexed_at = Time.now
  end

  def set_object_created_at
    self.object_created_at ||= object.created_at if object && object.respond_to?(:created_at)
  end

  def set_object_updated_at
    self.object_updated_at = object.updated_at if object && object.respond_to?(:updated_at)
  end

  def self.import(document_type, options)
    url = options.delete(:url)
    searchable = find_by_url(url) || create(url: url, object: options.delete(:object))
    searchable.attributes = {document_type: document_type}.merge(options || {})
    searchable.save
    searchable
  end
  
  def self.index_page(page)
    if page.approved? && !page.dynamic_content
      title = page.title
      content = with_helper {strip_tags page.content}
      url = page.path
      unless title.blank? && content.blank?
        import 'Page', url: url, title: title, content: content, object: page
      end
    end
  end

  def self.index_pages
    Page.approved.each { |page| index_page page }
  end

  def self.safe_get_text_command(command, file)
    begin
      if File.exists?(file)
        text = `#{command} #{file}`.force_encoding('UTF-8')
      else
        text = '' # TODO: or raise?
      end
    rescue Exception => e
      logger.info " ** Unable to #{command}: #{file} because #{e.inspect}"
    ensure
      return text || ''
    end
  end
  
  def self.get_text_from_pdf(system_path_to_file)
    puts "Get from pdf #{system_path_to_file}"
    safe_get_text_command("pdf2txt.py", system_path_to_file)
  end
  
  def self.timestamps_from(system_path_to_file)
    if system_path_to_file
      object = OpenStruct.new
      mtime = File.mtime(system_path_to_file)
      object.created_at, object.updated_at = mtime, mtime
      object
    end
  end
  
  def self.convert_to_utf8(text)
    converter = Iconv.new('UTF-8', text.encoding.name)
    converter.iconv(text)
  end
  
  def self.get_text_from_word(system_path_to_file)
    puts "Get from Word #{system_path_to_file}"
    safe_get_text_command("#{RAILS_ROOT}/script/word_import", system_path_to_file)
  end
  
  def self.index_pdf(system_path_to_file, public_path_to_file)
    title = 'PDF File'
    url   = public_path_to_file
    content = get_text_from_pdf(system_path_to_file)
    object  = timestamps_from(system_path_to_file)
    import 'PDF', url: url, title: title, content: content, object: object
  end

  def self.index_event(event)
    title = event.title
    content = event.location + "\n" + 
      event.country.try(:name) + 
      with_helper {strip_tags(event.description)}
    url = with_helper { event_path(event) }
    import 'Event', url: url, title: title, content: content, object: event
  end

  def self.index_events
    Event.approved.each { |e| index_event e }
  end
  
  def self.index_headline(headline)
    title = headline.title
    content = headline.location + "\n" + 
      headline.country.try(:name) + 
      with_helper { strip_tags(headline.description) }
    url = with_helper { headline_path(headline) }
    import 'Headline', url: url, title: title, content: content, object: headline
  end
  
  def self.index_headlines
    Headline.approved.each { |h| index_headline h }
  end

  def self.index_case_story(case_story)
    if case_story.approved?
      title = case_story.title
      if case_story.attachment_content_type =~ /^application\/.*pdf$/
        file_content = get_text_from_pdf(case_story.attachment.path)
      elsif case_story.attachment_content_type =~ /doc/
        file_content = get_text_from_word(case_story.attachment.path)
      end
      if object = timestamps_from(case_story.attachment.path)
        object.updated_at = case_story.updated_at if case_story.updated_at > object.updated_at
      else
        object = OpenStruct.new
        object.created_at, object.updated_at = case_story.created_at, case_story.updated_at
      end
      content = <<-EOF
        #{case_story.description}
        #{case_story.countries.map(&:name).join(' ')}
      EOF
      # FIXME: see http://tinyurl.com/ykdcmjt
      # Summary: ActiveRecord is casting all attributes to US-ASCII (!) but our 
      # file_content is coming in as UTF-8 - ruby will complain -- so force everything 
      # into the same encoding. Hopefully someone will patch ActiveRecord to make this 
      # obsolete, but for now...
      content = "#{content.force_encoding('UTF-8')} #{file_content}"
      url = "/case_story/#{case_story.to_param}"
      import 'CaseStory', url: url, title: title, content: content, object: object
    end
  end

  def self.index_case_stories
    CaseStory.approved.each { |c| index_case_story c }
  end

  def self.index_organization(organization)
    title   = organization.name
    content = ''
    url     = with_helper { participant_path(organization) }
    import 'Participant', url: url, title: title, content: content, object: organization
  end
  
  def self.index_organizations
    Organization.approved.each { |o| index_organization o }
  end
  
  def self.with_helper(&block)
    unless @helper
      @helper = SearchableHelper.new
    end
    @helper.instance_eval(&block)
  end

  def self.index_all
    index_pages
    index_events
    index_headlines
    index_case_stories
    index_organizations
  end
end
