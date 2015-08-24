require 'test_helper'

class CopsFeedTest < ActionDispatch::IntegrationTest
  setup do
    create_principle_area(name: "Human Rights")
    create_principle_area(name: "Labour")
    create_principle_area(name: "Environment")
    create_principle_area(name: "Anti-Corruption")

    @org_type = create_organization_type
    @org = create_organization
    @cop = create_communication_on_progress(cop_type: 'basic')
  end

  test 'should get feed' do
    visit feeds_cops_path

    feed = Nokogiri::XML(page.body)

    # assert something
  end
end
