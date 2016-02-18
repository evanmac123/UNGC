require 'test_helper'

class SdgPioneerMailerTest < ActionMailer::TestCase
  test "nomination_submitted" do
    other = create_sdg_pioneer_other
    mail = SdgPioneerMailer.nomination_submitted(other.id)
    assert_equal "A SDG Pioneer nomination was received", mail.subject
    assert_equal ["sdgpioneers@unglobalcompact.org"], mail.to
    assert_equal ["info@unglobalcompact.org"], mail.from
  end

end
