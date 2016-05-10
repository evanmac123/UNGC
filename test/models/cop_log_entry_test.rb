require 'test_helper'

class CopLogEntryTest < ActiveSupport::TestCase

  should 'keep a record of the contact even if they are deleted' do
    contact = create(:contact)
    log_entry = create(:cop_log_entry, contact: contact)

    contact.destroy!
    log_entry.reload

    assert_nil log_entry.contact
  end

end
