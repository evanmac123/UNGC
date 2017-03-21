class SalesforceSync
  attr_reader :jobs

  def self.sync(jobs)
    new(jobs).process
  end

  def initialize(jobs)
    @jobs = Array(jobs).map { |args| Job.create(args) }
  end

  def process
    jobs.map(&:execute).all?
  end

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
      update
    rescue ActiveRecord::RecordInvalid => e
      if deleting_an_unsynced_record?
        Rails.logger.warn "the record #{id} is being deleted, but we never had it in the first place. Ignoring."
      else
        raise e
      end
    end

    private

    def deleting_an_unsynced_record?
      record.valid? == false &&
        record.persisted? == false &&
        args.fetch(:is_deleted) == true
    end

  end

  class CampaignJob < Job
    def update
      Campaign.transaction do
        @campaign = Campaign.where(campaign_id: id).
          first_or_initialize
        @campaign.update!(args)
      end
    end

    def record
      @campaign
    end
  end

  class ContributionJob < Job
    def update
      Contribution.transaction do
        @contribution = Contribution.where(contribution_id: id).
          first_or_initialize
        @contribution.update!(args)
      end
    end

    def record
      @contribution
    end
  end
end
