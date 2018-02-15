# Preview all emails at http://localhost:3000/rails/mailers/sdg_pioneer_mailer
class SdgPioneerMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/sdg_pioneer_mailer/nomination_submitted
  def nomination_submitted
    nomination = FactoryBot.create(:sdg_pioneer_other)
    SdgPioneerMailer.nomination_submitted(nomination.id)
  end

  def email_nominee
    nomination = FactoryBot.create(:sdg_pioneer_other)
    SdgPioneerMailer.email_nominee(nomination.id)
  end

end
