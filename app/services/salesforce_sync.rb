class SalesforceSync
  attr_reader :jobs

  def self.sync(jobs)
    new(jobs).process
  end

  def initialize(jobs)
    @jobs = Array(jobs)
  end

  def process
    jobs.map do |job|
      find_or_create(job)
    end.all?
  end

  private

  def find_or_create(args)
    type = args.delete(:type)
    find_method = "find_ungc_#{type}".to_sym
    raise "unknown job type: #{type}" unless self.respond_to?(find_method, true)

    id = args.delete(:id)
    model = self.send(find_method, id).first_or_initialize
    model.update_attributes!(args)
  end

  def find_ungc_campaign(id)
    Campaign.where(campaign_id: id)
  end

  def find_ungc_contribution(id)
    Contribution.where(contribution_id: id)
  end
end
