class SalesforceSync
  attr_reader :jobs

  def self.sync(jobs)
    new(jobs).process
  end

  def initialize(jobs)
    @jobs = Array(jobs).map { |args| Job.new(args) }
  end

  def process
    jobs.map(&:execute).all?
  end

  private

  class Job

    def initialize(args)
      @id = args.delete(:id)
      @type = args.delete(:type)
      @args = args
    end

    def execute
      record.update_attributes!(args)
    rescue ActiveRecord::RecordInvalid => e
      if deleting_an_unsynced_record?
        Rails.logger.warn "the #{type} record #{id} is being deleted, but we never had it in the first place. Ignoring."
      else
        raise e
      end
    end

    private

    attr_reader :id, :type, :args

    def record
      case type
      when 'campaign'
        find_campaign(id)
      when 'contribution'
        find_contribution(id)
      else
        raise "unknown salesforce sync type: #{type}"
      end
    end

    def find_campaign(id)
      Campaign.where(campaign_id: id).first_or_initialize
    end

    def find_contribution(id)
      Contribution.where(contribution_id: id).first_or_initialize
    end

    def deleting_an_unsynced_record?
      record.valid? == false &&
        record.persisted? == false &&
        args.fetch(:is_deleted) == true
    end

  end

end
