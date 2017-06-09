class IglooSignInTracker
  include Sidekiq::Worker

  def self.track(contact)
    self.perform_async(contact.id)
  end

  def perform(contact_id)
    igloo_user = IglooUser.find_by(contact_id: contact_id)
    if igloo_user.present?
      igloo_user.touch
    else
      IglooUser.create!(contact_id: contact_id)
    end
  end

end
