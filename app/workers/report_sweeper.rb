class ReportSweeper
  include Sidekiq::Worker

  def self.sweep(status)
    perform_in(30.minutes, status.id)
  end

  def perform(status_id)
    status = ReportStatus.find_by(status_id)
    if status.present?
      status.cleanup
      status.destroy
    end
  end

end
