require 'test_helper'

class AllCopsTest < ActiveSupport::TestCase

  test "reports on all COPs" do
    create_list(:communication_on_progress, 3)
    report = AllCops.new
    assert_equal 3, report.records.count
  end

  test "renders participant_name" do
    organization = create(:organization, name: 'ACME Boxes')
    cop = create(:communication_on_progress, organization: organization)
    report = AllCops.new
    assert_equal 'ACME Boxes', report.row(cop).first
  end

  test "renders country" do
    country = create(:country, name: 'Canada')
    organization = create(:organization, country: country)
    cop = create(:communication_on_progress, organization: organization)
    report = AllCops.new
    assert_equal 'Canada', report.row(cop)[1]
  end

  test "renders cop_web_link" do
    cop = create(:communication_on_progress, id: 123)
    report = AllCops.new
    assert_equal 'http://www.unglobalcompact.org/COPs/detail/123', report.row(cop)[2]
  end

  test "renders id" do
    cop = create(:communication_on_progress, id: 123)
    report = AllCops.new
    assert_equal 123, report.row(cop)[3]
  end

  test "renders organization_id" do
    organization = create(:organization, id: 123)
    cop = create(:communication_on_progress, organization: organization)
    report = AllCops.new
    assert_equal 123,  report.row(cop)[4]
  end

  test "renders title" do
    cop = create(:communication_on_progress, title: 'Hello')
    report = AllCops.new
    assert_equal 'Hello', report.row(cop)[5]
  end

  test "renders contact_info" do
    # FIXME not sure how to test this
    # The code seems wrong
    # see: app/reports/all_cops.rb#single_line
    # the pattern is \r\n? which assumes Windows line endings and expects a trailing character, which also seems wrong
    contact = create(:contact, {
      prefix: 'Mrs',
      first_name: 'Gloria',
      last_name: 'Steinem',
      job_title: 'Journalist',
      email: 'gs@example.com',
      phone: '+1 (123)456-7890'

    })
    cop = create(:communication_on_progress, contact_info: contact.contact_info)
    report = AllCops.new
    assert_equal "Mrs Gloria Steinem\nJournalist\ngs@example.com\n+1 (123)456-7890", report.row(cop)[6]
  end

  test "renders include_actions" do
    cop = create(:communication_on_progress, include_actions: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[7]
  end

  test "renders include_measurement" do
    cop = create(:communication_on_progress, include_measurement: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[8]
  end

  test "renders use_indicators" do
    cop = create(:communication_on_progress, use_indicators: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[9]
  end

  test "renders cop_score_id" do
    cop = create(:communication_on_progress, cop_score_id: 321)
    report = AllCops.new
    assert_equal 321, report.row(cop)[10]
  end

  test "renders use_gri" do
    cop = create(:communication_on_progress, use_gri: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[11]
  end

  test "renders has_certification" do
    cop = create(:communication_on_progress, has_certification: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[12]
  end

  test "renders notable_program" do
    cop = create(:communication_on_progress, notable_program: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[13]
  end

  test "renders created_at" do
    time = DateTime.new(2015, 1, 2, 3, 4, 5, 6, 7)
    cop = create(:communication_on_progress, created_at: time)
    report = AllCops.new
    assert_equal "2015-01-02 03:04:05", report.row(cop)[14]
  end

  test "renders updated_at" do
    time = DateTime.new(2015, 1, 2, 3, 4, 5, 6, 7)
    cop = create(:communication_on_progress, updated_at: time)
    report = AllCops.new
    assert_equal "2015-01-02 03:04:05", report.row(cop)[15]
  end

  test "renders published_on" do
    time = Date.new(2015, 1, 2, 3)
    cop = create(:communication_on_progress, published_on: time)
    report = AllCops.new
    assert_equal time, report.row(cop)[16]
  end

  test "renders state" do
    cop = create(:communication_on_progress)
    report = AllCops.new
    assert_equal "approved", report.row(cop)[17]
  end

  test "renders include_continued_support_statement" do
    cop = create(:communication_on_progress, include_continued_support_statement: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[18]
  end

  test "renders format" do
    cop = create(:communication_on_progress, format: "example")
    report = AllCops.new
    assert_equal "example", report.row(cop)[19]
  end

  test "renders references_human_rights" do
    cop = create(:communication_on_progress, references_human_rights: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[20]
  end

  test "renders references_labour" do
    cop = create(:communication_on_progress, references_labour: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[21]
  end

  test "renders references_environment" do
    cop = create(:communication_on_progress, references_environment: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[22]
  end

  test "renders references_anti_corruption" do
    cop = create(:communication_on_progress, references_anti_corruption: true)
    report = AllCops.new
    assert_equal 1, report.row(cop)[23]
  end

  test "renders meets_advanced_criteria" do
    cop = create(:communication_on_progress, cop_type: 'advanced')
    report = AllCops.new
    assert_equal 1, report.row(cop)[24]
  end

  test "renders additional_questions" do
    # advanced cops require additional_questions
    cop = create(:communication_on_progress, cop_type: 'advanced')
    report = AllCops.new
    assert_equal 1, report.row(cop)[25]
  end

  test "renders method_shared" do
    cop = create(:communication_on_progress, method_shared: "method_name")
    report = AllCops.new
    assert_equal "method_name", report.row(cop)[26]
  end

  test "renders starts_on" do
    time = Date.new(2015, 1, 2, 3)
    cop = create(:communication_on_progress, starts_on: time)
    report = AllCops.new
    assert_equal time, report.row(cop)[27]
  end

  test "renders ends_on" do
    time = Date.new(2015, 1, 2, 3)
    cop = create(:communication_on_progress, ends_on: time)
    report = AllCops.new
    assert_equal time, report.row(cop)[28]
  end

  test "renders differentiation" do
    cop = create(:communication_on_progress)
    report = AllCops.new
    assert_equal "learner", report.row(cop)[29]
  end

end
