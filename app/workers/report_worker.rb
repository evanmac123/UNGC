class ReportWorker
  include Sidekiq::Worker

  def self.generate_xls(report, filename, skip_sweep: false)
    status = ReportStatus.create!(
      filename: filename,
      format: 'xls',
    )
    perform_async(status.id, report.class.name, report.options, skip_sweep)
    status
  end

  def perform(status_id, class_name, opts, skip_sweep)
    options   = (opts || {}).with_indifferent_access
    report    = class_name.constantize.new(options)
    status    = ReportStatus.find(status_id)
    file_path = report.render_output
    status.complete!(file_path)
  rescue => e
    status.failed!(e) if status
    raise e
  ensure
    ReportSweeper.sweep(status) if status && !skip_sweep
  end

end
