class ContactUsMailerPreview < ActionMailer::Preview

  def contact_us_received
    ContactUsMailer.contact_us_received(params)
  end

  private

  def params
    @params = {
      name: 'Human',
      email: 'haha@human.com',
      organization: 'Planet Earth',
      interest: 'Living',
      focuses: 'Staying alive',
      comments: 'This mailer preview is not neccessary'
    }
  end

end
