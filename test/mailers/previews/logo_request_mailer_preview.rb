class LogoRequestMailerPreview < ActionMailer::Preview

  def in_review
    LogoRequestMailer.in_review(logo_request)
  end

  def approved
    LogoRequestMailer.approved(logo_request)
  end

  def rejected
    LogoRequestMailer.rejected(logo_request)
  end

  private

  def logo_request
    @logo_request ||= FactoryGirl.create(:logo_request, logo_comments: [logo_comment], contact: contact)
  end

  def logo_comment
    @logo_comment ||= FactoryGirl.create(:logo_comment, contact: contact)
  end

  def contact
    @contact ||= FactoryGirl.create(:contact, country: country)
  end

  def country
    @country ||= FactoryGirl.create(:country, local_network: local_network)
  end

  def local_network
    @local_network ||= FactoryGirl.create(:local_network)
  end

end
