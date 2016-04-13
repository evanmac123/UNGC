require 'test_helper'

class CopsFeedTest < ActionDispatch::IntegrationTest
  setup do
    create(:principle_area, name: "Human Rights")
    create(:principle_area, name: "Labour")
    create(:principle_area, name: "Environment")
    create(:principle_area, name: "Anti-Corruption")

    @org_type = create(:organization_type)
    @org = create(:organization)
    @cop = create(:communication_on_progress, cop_type: 'basic')
  end

  test 'should get feed' do
    visit feeds_cops_path

    feed = Nokogiri::XML(page.body)

    # assert something
  end
end
