class BackdateCommunicationOnProgress

  def self.backdate(communication, date)
    new(communication, date).backdate
  end

  attr_reader :communication, :date

  def initialize(communication, date)
    @communication, @date = communication, date
  end

  def backdate
    Organization.transaction do
      update_published_on && update_status_on_most_recent_communication
    end
  end

  private

    def update_published_on
      communication.update_attribute(:published_on, date)
    end

    def update_status_on_most_recent_communication
      if most_recent_communication?
        cop_due_on = date + organization.years_until_next_cop_due.years
        organization.set_next_cop_due_date_and_cop_status(cop_due_on)
      else
        true
      end
    end

    def most_recent_communication?
      organization.communication_on_progresses.approved.first == communication
    end

    def organization
      communication.organization
    end

end
