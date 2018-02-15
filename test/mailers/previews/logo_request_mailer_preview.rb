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
    @logo_request ||= FactoryBot.create(:logo_request, logo_comments: [logo_comment], contact: contact)
  end

  def logo_comment
    @logo_comment ||= FactoryBot.create(:logo_comment, contact: contact)
  end

  def contact
    @contact ||= FactoryBot.create(:contact, country: country)
  end

  def country
    @country ||= FactoryBot.create(:country, local_network: local_network)
  end

  def local_network
    @local_network ||= FactoryBot.create(:local_network)
  end

end
