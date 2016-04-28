class UpgradePasswordHash
  include Sidekiq::Worker

  INTERVAL = 5.seconds

  def self.upgrade_all
    perform_async
  end

  def perform
    process
    if next_batch.any?
      enqueue
    else
      all_done
    end
  end

  private

  def process
    next_batch.each do |contact|
      contact.password = contact.plaintext_password_disabled
      contact.password_upgraded = true

      # not all existing contacts have valid attributes
      contact.save!(validate: false)
    end
  end

  def enqueue
    UpgradePasswordHash.perform_in(INTERVAL)
  end

  def all_done
    SampleMailer.sample('ben@bitfield.co', 'done upgrade password hashes').deliver
  end

  def self.next_batch
    Contact.
      where.not(plaintext_password_disabled: nil).
      where(password_upgraded: false).
      limit(10)
  end

  def next_batch
    self.class.next_batch
  end

end
