class ReportingCycleAdjustmentApplication
  MAX_MONTHS = 11

  attr_reader :organization
  attr_accessor :reporting_cycle_adjustment

  def self.eligible?(organization)
    new(organization).valid?
  end

  def self.submit_for(organization, reporting_cycle_adjustment, due_date)
    new(organization).submit(reporting_cycle_adjustment, due_date)
  end

  def initialize(organization)
    @organization = organization
  end

  def valid?
    [delisted?, already_submitted?].none?
  end

  def submit(reporting_cycle_adjustment, due_date)
    if valid?
      save(reporting_cycle_adjustment, due_date) && update_organization_due_date(reporting_cycle_adjustment)
    else
      false
    end
  end

  def errors
    @errors ||= []
  end

  private

    def delisted?
      if organization.delisted?
        errors << "Cannot submit a reporting cycle adjustment for a delisted organization"
      end
    end

    def already_submitted?
      if ReportingCycleAdjustment.has_submitted?(organization)
        errors << "Cannot submit more than one reporting cycle adjustment"
      end
    end

    def save(reporting_cycle_adjustment, due_date)
      reporting_cycle_adjustment.starts_on = Date.today
      reporting_cycle_adjustment.ends_on = due_date
      reporting_cycle_adjustment.save!
    end

    def update_organization_due_date(reporting_cycle_adjustment)
      organization.update_attributes!(cop_due_on: reporting_cycle_adjustment.ends_on, active: true)
    end

end
