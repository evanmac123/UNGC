class CaseStoryMailer < ActionMailer::Base
  default :from => EMAIL_SENDER

  def in_review(case_story)
    @case_story = case_story
    mail(:to => case_story.contact.email, :subject => "Your Global Compact Case Story has been updated")
  end

  def approved(case_story)
    @case_story = case_story    
    mail(:to => case_story.contact.email, :subject => "Your Global Compact Case Story has been accepted")
  end

  def rejected(case_story)
    @case_story = case_story
    mail(:to => case_story.contact.email, :subject => "Global Compact Case Story Status")
  end
end
