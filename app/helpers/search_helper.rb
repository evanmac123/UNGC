module SearchHelper
  def format(result)
    response = result.excerpts.content
    begin
      response = response.force_encoding("UTF-8")
    rescue
    end
    response.gsub!('&amp;nbsp;', ' ')
    response.gsub!(/&amp;gt(;)?/, '>')
    response.gsub!(/&amp;(n|m)dash;/, '-')
    response.html_safe
  end

  def pretty_facet_label(key)
    prettier = {
      'CaseStory' => 'Case Stories',
      'CommunicationOnProgress' => 'COPs',
      'Event' => 'Events',
      'Headline' => 'News items',
      'Participant' => 'Participants',
      'Page' => 'Web pages',
      'Resource' => 'Tools and Resources',
    }[key]
  end
  
  def results_description(params)
    params[:document_type].present? ? pretty_facet_label(params[:document_type]) : "Search results"
  end
  
end
