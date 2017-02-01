require "test_helper"
require "sidekiq/testing"

class InitiativeCopsTest < ActiveSupport::TestCase

  # things to test:
  # #records filters by initiative and the date range
  # #row(answer) and #headers format correctly
  # The report works within the context of a ReportWorker

  test "works" do
    # Given a weps question and attribute
    weps_question = create(:cop_question,
                           initiative_id: Initiative.id_by_filter(:weps))
    weps_attribute = create(:cop_attribute, cop_question: weps_question)

    # And a COP published today
    organization = create(:organization,
                          name: "Super Org",
                          sector: Sector.find_by(name: "Beverages"))
    cop = create(:communication_on_progress,
                 published_on: Date.today,
                 organization: organization)

    # And a weps answer
    weps_answer = create(:cop_answer, cop_attribute: weps_attribute,
                         text: "hi", value: true, communication_on_progress: cop)

    date_range = 5.day.ago..5.day.from_now
    report = InitiativeCops.new(date_range: date_range,
                                initiative_name: :weps)

    assert_equal [weps_answer], report.records

    # TODO fill out all the properties of Organization, COP and Answer
    # and then look for them in the output of row(answer)
    # expected = [
    #   "Super Org",
    #   "Company",
    # ]
    # assert_equal expected, report.row(weps_answer)
  end

  test "works from Worker" do
    Sidekiq::Testing.inline! do
      # Given a weps question and attribute
      weps_question = create(:cop_question,
                             initiative_id: Initiative.id_by_filter(:weps))
      weps_attribute = create(:cop_attribute, cop_question: weps_question)

      # And a COP published today
      organization = create(:organization,
                            name: "Super Org",
                            sector: Sector.find_by(name: "Beverages"))
      cop = create(:communication_on_progress,
                   published_on: Date.today,
                   organization: organization)

      # And a weps answer
      weps_answer = create(:cop_answer, cop_attribute: weps_attribute,
                           text: "hi", value: true, communication_on_progress: cop)

      date_range = 5.day.ago..5.day.from_now
      report = InitiativeCops.new(date_range: date_range,
                                  initiative_name: :weps)
      status = ReportWorker.generate_xls(report, "test-filename.xls", skip_sweep: true)
      status.reload
      assert_match(/Super Org/, File.read(status.path))

      File.delete(status.path)
    end
  end

  private

  def create_answer(initiative_name)
    initiative_id = Initiative.id_by_filter(initiative_name)
    question = create(:cop_question, initiative_id: initiative_id)
    attribute = create(:cop_attribute, cop_question: question)
    create(:cop_answer, cop_attribute: attribute)
  end

end
