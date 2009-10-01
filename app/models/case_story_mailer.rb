class CaseStoryMailer < ActionMailer::Base
  def in_review(case_story)
    from EMAIL_SENDER
    subject "Your Global Compact Case Story has been updated"
    content_type "text/html"
    recipients case_story.contact.email
    body :case_story => case_story
  end
  
  def approved(case_story)
    from EMAIL_SENDER
    subject "Your Global Compact Case Story has been accepted"
    content_type "text/html"
    recipients case_story.contact.email
    body :case_story => case_story
  end

  def rejected(case_story)
    from EMAIL_SENDER
    subject "Global Compact Case Story Status"
    content_type "text/html"
    recipients case_story.contact.email
    body :case_story => case_story
  end
end
