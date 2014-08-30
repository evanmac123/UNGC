require 'test_helper'

class ContributionLevelsTest < ActionDispatch::IntegrationTest

  setup do
    create_staff_user
    login_as @staff_user

    @network = create_local_network
    @levels = @network.contribution_levels
    @levels.level_description = 'Levels'
    @levels.amount_description = 'Amount'
    @levels.pledge_description = 'Pledge Description'
    @levels.add(description: 'level1', amount: '$10,000')
    @levels.add(description: 'level2', amount: '$20,000')
    @levels.save!

    visit edit_admin_local_network_path(@network, section: 'fees_contributions')
  end

  should "have a legend" do
    legend = find ".contribution_levels legend"
    assert_equal 'Contribution/fee level(s) and corresponding amount(s)', legend.text
  end

  should "show the level description" do
    description = find("#level-description").text
    assert_equal 'Level Description', description
  end

  should "show the amount description" do
    description = find("#amount-description").text
    assert_equal 'Amount Description', description
  end

  should "show edit boxes for description" do
    descriptions = all_contribution_levels('description')
    assert_equal ['level1', 'level2'], descriptions.map(&:value)
  end

  should "show edit boxes for amount" do
    amounts = all_contribution_levels('amount')
    assert_equal ['$10,000', '$20,000'], amounts.map(&:value)
  end

  should "round trip contribution levels" do
    # Since our form relies on javascript we can't add or remove items
    # from the integration test. We'll settle for testing that we can roundtrip
    # and catch the rest in controller tests.
    click_on 'Save changes'

    assert_equal 200, page.status_code
    assert_equal admin_local_network_path(@network), current_path

    @network.reload
    levels = @network.contribution_levels
    assert_equal %w(level1 level2), levels.map(&:description)
    assert_equal %w($10,000 $20,000), levels.map(&:amount)
  end

  def all_contribution_levels(field)
    name = "local_network[contribution_levels][levels][]#{field}"
    all("input[name='#{name}']")
  end

end
