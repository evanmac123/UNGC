require 'test_helper'

class SponsorTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should reject large invalid logo url" do
    sponsor = Sponsor.new(name: "blah", logo_url: "http://goodlink.com/B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1")
    assert_not sponsor.valid?
  end

  test "should reject large invalid website url" do
    sponsor = Sponsor.new(name: "blah", website_url: "http://goodlink.com/B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1")
    assert_not sponsor.valid?
  end
end
