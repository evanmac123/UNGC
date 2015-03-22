class ReportSweeper
  include Sidekiq::Worker

  def self.sweep(status)
    perform_in(30.minutes, status.id)
  end

  def perform(status_id)
    status = ReportStatus.find(status_id)

    return unless status

    if status.path && File.exist?(status.path)
      File.unlink(status.path)
    end

    status.destroy
  end

end

