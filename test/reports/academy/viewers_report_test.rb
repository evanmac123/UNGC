class Academy::ViewersReportTest < ActiveSupport::TestCase

  test "it includes academy viewers from organizations" do
    organization = create(:organization)
    contact = create(:contact,
                     organization: organization,
                     roles: [Role.academy_viewer])

    report = Academy::ViewersReport.new
    record = report.to_h&.first

    assert_equal contact.id, record["Contact ID"]
    assert_equal contact.name, record["Name"]
    assert_equal contact.email, record["Email"]
    assert_equal contact.created_at.to_s, record["Created at"].to_s
    assert_equal organization.name, record["Organization Name"]
    assert_nil record["Local Network Name"]
  end

  test "it includes acadmey viewers from local networks" do
    network = create(:local_network)
    contact = create(:contact,
                     local_network: network,
                     roles: [Role.academy_viewer])

    report = Academy::ViewersReport.new
    record = report.to_h&.first

    assert_nil record["Organization Name"]
    assert_equal network.name, record["Local Network Name"]
  end

end
