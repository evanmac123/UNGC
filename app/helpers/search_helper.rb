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
      'Headline' => 'News',
      'Participant' => 'Participants',
      'Page' => 'Pages',
      'Resource' => 'Resources',
    }[key]
  end
end
