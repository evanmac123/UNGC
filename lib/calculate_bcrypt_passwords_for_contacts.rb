# nice -19 bin/rails r 'CalculateBcryptPasswordsForContacts.new.run' -e production

class CalculateBcryptPasswordsForContacts
  def run
    Contact.where('plaintext_password_disabled is not null').find_each do |contact|
      contact.password = contact.plaintext_password_disabled
      contact.save!(validate: false) # not all existing contacts have valid attributes
    end
  end
end
