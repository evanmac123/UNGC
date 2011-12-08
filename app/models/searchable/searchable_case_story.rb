module Searchable::SearchableCaseStory
  def index_case_story(case_story)
    if case_story.approved?
      title = case_story.title
      file_content = FileTextExtractor.extract(case_story)
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
      url = "/case_story/#{case_story.id}"
      import 'CaseStory', url: url, title: title, content: content, object: object
    end
  end

  def index_case_stories
    CaseStory.approved.each { |c| index_case_story c }
  end

  def index_case_stories_since(time)
    CaseStory.approved.find(:all, conditions: new_or_updated_since(time)).each { |c| index_case_story c }
  end

end
