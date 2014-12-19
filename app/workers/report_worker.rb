class ReportWorker
  include Sidekiq::Worker

  def self.generate_xls(report, filename)
    status = ReportStatus.create!(
      filename: filename,
      format: 'xls',
    )
    perform_async(status.id, report.class.name, report)
    status
  end

  def perform(status_id, class_name, args)
    options = args.fetch('options').with_indifferent_access
    report = class_name.constantize.new(options)

    status = ReportStatus.find(status_id)
    file = report.render_output
    status.complete!(file)
  rescue => e
    status.failed!(e)
    raise e
  ensure
    ReportSweeper.sweep(status) if status
    file.close if file
  end

end
