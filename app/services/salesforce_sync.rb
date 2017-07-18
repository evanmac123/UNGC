class SalesforceSync
  attr_reader :jobs

  def self.sync(jobs)
    new(jobs).process
  end

  class Worker
    include Sidekiq::Worker

    def perform(jobs)
      sync = SalesforceSync.new(jobs)
      sync.process
    end

  end

  def self.sync_async(jobs)
    Worker.perform_async(jobs)
  end

  def initialize(jobs)
    @jobs = Array(jobs).map { |args| Job.create(args) }
  end

  def process
    jobs.map(&:execute).all?
  end

  # Abstract job for syncing a model
  class Job
    attr_reader :id, :args

    def self.create(args)
      type = args.delete(:type)
      id = args.delete(:id)
      args = args

      case type
      when 'campaign'
        CampaignJob.new(id, args)
      when 'contribution'
        ContributionJob.new(id, args)
      else
        raise "unknown salesforce sync type: #{type}"
      end
    end

    def initialize(id, args)
      @id = id
      @args = args
    end

    def execute
      transaction do
        record = find_record(id)
        if record.present?
          record.update!(args)
        elsif args[:is_deleted] == true
          Rails.logger.warn(<<-WARNING)
            The record #{id} is being deleted, but we never had it
            in the first place. Ignoring the command.
          WARNING
          nil
        else
          begin
            create_record(args)
          rescue ActiveRecord::RecordNotUnique
            record = find_record(id)
            record.update!(args)
          end
        end
      end
    end
  end

  # Syncs a Campaign
  class CampaignJob < Job
    def transaction(&block)
      Campaign.transaction(&block)
    end

    def find_record(id)
      Campaign.find_by(campaign_id: id)
    end

    def create_record(args)
      Campaign.create!(args.merge(campaign_id: id))
    end
  end

  # Syncs a Contribution
  class ContributionJob < Job
    def transaction(&block)
      Contribution.transaction(&block)
    end

    def find_record(id)
      Contribution.find_by(contribution_id: id)
    end

    def create_record(args)
      Contribution.create!(args.merge(contribution_id: id))
    end
  end
end
