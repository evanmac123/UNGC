require 'test_helper'

class ReportSweeperTest < ActiveSupport::TestCase

  should "destroy a status object and delete it's file" do
    path = 'tmp/meow.txt'
    FileUtils.touch(path)
    status = create(:report_status, path: path)

    ReportSweeper.new.perform(status.id)

    assert_not File.exist?(path)
  end

  should "destroy a status object when the file doesn't exist" do
    status = create(:report_status)

    ReportSweeper.new.perform(status.id)

    assert_nil ReportStatus.find_by(id: status.id)
  end

  should "complete silently if the status cannot be found" do
    ReportSweeper.new.perform(12345)
  end

end
