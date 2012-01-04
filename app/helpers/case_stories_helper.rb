module CaseStoriesHelper

  def formatted_authors(authors)
    if authors.any?
      authors.map { |author| content_tag :p, formatted_email_link_to(author) }.join("\n")
    else
      'Unknown authors'
    end
  end

  def formatted_email_link_to(formatted_contact)
    if formatted_contact
      "#{formatted_contact.name}, #{formatted_contact.institution}<br />
      #{link_to_unless(formatted_contact.email.blank?, formatted_contact.email, "mailto:#{formatted_contact.email}")}"
    else
      'None'
    end
  end

  def formatted_links(links)
    if links.any?
      list = links.map do |object|
        if object.is_a?(Paperclip::Attachment)
          content_tag :li, link_to('Case Story Attachment', object.url)
        else
          content_tag :li, link_to(object, object)
        end
      end
      content_tag :ul, list.join("\n")
    end
  end

  def issues_addressed(issues)
    if issues.any?
      list = issues.map { |issue| content_tag :li, issue.name }
      content_tag :ul, list.join("\n")
    end
  end
end
