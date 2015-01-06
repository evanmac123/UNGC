class ReportWorker
  include Sidekiq::Worker

  def self.generate_xls(report, filename)
    status = ReportStatus.create!(
      filename: filename,
      format: 'xls',
    )
    perform_async(status.id, report.class.name, report.options)
    status
  end

  def perform(status_id, class_name, opts)
    options = (opts || {}).with_indifferent_access
    report  = class_name.constantize.new(options)
    status  = ReportStatus.find(status_id)
    file    = report.render_output
    status.complete!(file)
  rescue => e
    status.failed!(e) if status
    raise e
  ensure
    ReportSweeper.sweep(status) if status
    file.close if file
  end

end
