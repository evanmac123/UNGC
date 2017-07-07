module Igloo
  class CsvAdapter

    def to_csv(contacts)
      CSV.generate(headers: DEFAULTS.keys,
        write_headers: true) do |csv|
        Array.wrap(contacts).each do |contact|
          csv << single(contact).values
        end
      end
    end

    private

    def single(contact)
      contact.reverse_merge(DEFAULTS)
    end

    DEFAULTS = {
      "firstname" => nil,
      "lastname" => nil,
      "email" => nil,
      "customIdentifier" => nil,
      "bio" => nil,
      "birthdate" => nil,
      "gender" => nil,
      "address" => nil,
      "address2" => nil,
      "city" => nil,
      "state" => nil,
      "zipcode" => nil,
      "country" => nil,
      "cellphone" => nil,
      "fax" => nil,
      "busphone" => nil,
      "buswebsite" => nil,
      "company" => nil,
      "department" => nil,
      "occupation" => nil,
      "sector" => nil,
      "im_skype" => nil,
      "im_googletalk" => nil,
      "im_msn" => nil,
      "im_aol" => nil,
      "s_facebook" => nil,
      "s_linkedin" => nil,
      "s_twitter" => nil,
      "website" => nil,
      "blog" => nil,
      "associations" => nil,
      "hobbies" => nil,
      "interests" => nil,
      "skills" => nil,
      "isSAML" => nil,
      "managedByLdap" => nil,
      "s_google" => nil,
      "status" => nil,
      "extension" => nil,
      "i_report_to" => nil,
      "i_report_to_email" => nil,
      "im_skypeforbusiness" => nil,
      "groupsToAdd" => nil,
      "groupsToRemove" => nil,
    }.freeze
  end
end
