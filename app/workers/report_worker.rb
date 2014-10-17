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
    status.complete!(report.render_output)
  rescue => e
    status.failed!(e)
    raise e
  end

end
