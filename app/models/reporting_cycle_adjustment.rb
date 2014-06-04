class ReportingCycleAdjustment
  # Reproting Cycle Adjustments are currently part of the CommunicationOnProgress table
  # this class is currently just a collection of class methods to consolidate concerns.
  # This may become it's own active record class in the future.
  TYPE = 'reporting_cycle_adjustment'.freeze

  DEFAULTS = {
    format: TYPE,
    title: 'Reporting Cycle Adjustment',
  }

  def self.new(params={})
    CommunicationOnProgress.new(DEFAULTS.merge(params))
  end

  def self.has_submitted?(organization)
    organization.communication_on_progresses.where(format: TYPE).count > 0
  end

end

