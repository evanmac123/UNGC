class CommunicationOnProgress::LearnerPolicy

  def initialize(organization)
    @organization = organization
  end

  def is_triple_learner?
    return false if cop_total < 3

    return false unless @organization.communication_on_progresses[0].learner? &&
      @organization.communication_on_progresses[1].learner? &&
      @organization.communication_on_progresses[2].learner?

    time_in_between_cops
  end

  def is_double_learner?
    if last_cop_is_learner? &&  cop_total > 1
      @organization.communication_on_progresses[1].learner?
    end
  end

  def last_cop_is_learner?
    last_approved_cop && last_approved_cop.learner?
  end

  private

  def gather_cops
    # gather learner COPs
    cops_collection = []
    cops.order('published_on DESC').each do |cop|
      next if cop.is_grace_letter? || cop.is_reporting_cycle_adjustment?
      cops_collection << cop if cop.learner?
    end
    cops_collection
  end

  def time_in_between_cops
    # check if the total time between first and last COP is two years
    cops = gather_cops
    first_cop   = cops.last
    second_cop  = cops.first
    months_between_cops = (first_cop.published_on.month - second_cop.published_on.month) + 12 * (first_cop.published_on.year - second_cop.published_on.year)
    months_between_cops = months_between_cops.abs
    if months_between_cops == 12
      # same month, so compare date
      first_cop.published_on.day <= second_cop.published_on.day
    else
      months_between_cops >= 12
    end

  end

  def cop_total
    cops.approved.count
  end

  def last_approved_cop
    cops.first if has_cop
  end

  def has_cop
    cops.any?
  end

  def last_approved_cop_id
    last_approved_cop.id if last_approved_cop
  end

  def last_approved_cop_year
    last_approved_cop.published_on.year if last_approved_cop
  end

  def cops
    @organization.communication_on_progresses.approved
  end

end
