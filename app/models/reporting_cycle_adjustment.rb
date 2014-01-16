class ReportingCycleAdjustment
  # Reproting Cycle Adjustments are currently part of the CommunicationOnProgress table
  # this class is currently just a collection of class methods to consolidate concerns.
  # This may become it's own active record class in the future.
  REPORT_CYCLE_ADJUSTMENT = 'reporting_cycle_adjustment'.freeze

  DEFAULTS = {
    format: REPORT_CYCLE_ADJUSTMENT,
    title: 'Reporting Cycle Adjustment',
  }

  def self.new(params={})
    CommunicationOnProgress.new(DEFAULTS.merge(params))
  end

end

