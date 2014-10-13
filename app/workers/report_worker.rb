class ReportWorker
  include Sidekiq::Worker

  def self.render_report(report, filename)
    status = ReportStatus.create! filename: filename
    perform_async(status.id, report.class.name, report)
    status
  end

  def perform(status_id, report_class, args)
    Rails.logger.info ["Performming: ", status_id, report_class, args]
    report = report_class.constantize.new(args)
    status = ReportStatus.find(status_id)

    # TODO handle failure case.
    status.complete!(report.render_output)
  end

end
