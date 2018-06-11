class SalesforceSync
  attr_reader :jobs

  def self.sync(jobs)
    new(jobs).process
  end

  def self.sync_async(jobs)
    Worker.perform_async(jobs)
  end

  def initialize(jobs)
    @jobs = Array(jobs)
  end

  def process
    m = method(:process_one)
    jobs.map(&m).all?
  end

  private

  def process_one(job_args)
    args = job_args.with_indifferent_access

    type = args.delete(:type)
    id = args.delete(:id)
    model_class = type.titlecase.constantize
    field = "#{type}_id"

    model_class.with_advisory_lock(id) do
      model_class.transaction do
        record = model_class.find_by(field => id)
        case
        when record.nil? && args[:is_deleted] == true
          show_delete_warning(id)
        when record.nil?
          model_class.create!(args.merge(field => id))
        when record.present?
          record.update!(args)
        end
      end
    end
  end

  def show_delete_warning(id)
    Rails.logger.warn(<<-WARNING)
            The record #{id} is being deleted, but we never had it
            in the first place. Ignoring the command.
          WARNING
  end

  class Worker
    include Sidekiq::Worker

    def perform(jobs)
      sync = SalesforceSync.new(jobs)
      sync.process
    end

  end

end
