require 'test_helper'

class ResourceLinkTest < ActiveSupport::TestCase
  should belong_to :resource
  should belong_to :language

  context "resource link creation" do

    should "create a valid resource link" do
      resource_link = ResourceLink.new title: "resource title 1", link_type: "pdf"
      assert resource_link.valid?, resource_link.errors.full_messages.to_sentence
    end

    should "not create an invalid resource link" do
      resource_link = ResourceLink.new title: "resource title 1", link_type: ResourceLink::TYPES[:pdf]
      refute resource_link.valid?, resource_link.errors.full_messages.to_sentence
    end

    should "not create an invalid resource link url" do
      resource_link = ResourceLink.new title: "blah", link_type: "pdf", url: "B3lBn76KKzCmOvp7EVomvPSEsiwsE3Bo0H1WhhyZK6Xq5Co2wL0W2x8swBpqOvJ1xiUcUhBNnDuIceTTNyJa5Yj1q4qinFYBpg4VXbYiOeehI9G2V3oJjhiBWqS05YSHQyZBAKGcnO7njnL9A1vq5kBNB01yBSCIZ3Lb4uDMfZScmv7KMgrsGixzq46aL3IJQW8MH37loOlMU4NPVWAh0HMlMUDlDQsf48T9895kbtZ7z8JDYs8WUXsyNlrwcTv1"
      refute resource_link.valid?, resource_link.errors.full_messages.to_sentence
    end

  end
end
