class GraceLetterApplication
  GRACE_DAYS = 90

  attr_reader :organization
  attr_accessor :grace_letter

  def self.eligible?(organization)
    new(organization).valid?
  end

  def self.submit(organization, cop_file)
    new(organization).submit(cop_file)
  end

  def initialize(organization)
    @organization = organization
    @grace_letter = GraceLetter.new(organization: organization)
  end

  def valid?
    [delisted?, already_extended?].none?
  end

  def extended_due_date
    organization.cop_due_on + GRACE_DAYS.days
  end

  def submit(cop_file)
    if valid?
      save(cop_file) && update_due_date
    else
      false
    end
  end

  def errors
    @error ||= []
  end

  private

    def delisted?
      if organization.delisted?
        errors << "Cannot submit a grace letter for a delisted organization"
      end
    end

    def already_extended?
      cops = organization.communication_on_progresses.approved
      if cops.any? && cops.first.is_grace_letter?
        errors << "Cannot submit two grace letters in a row"
      end
    end

    def save(cop_file)
      grace_letter.starts_on = organization.cop_due_on
      grace_letter.ends_on = extended_due_date
      grace_letter.cop_files = [cop_file]
      cop_file.save!
      grace_letter.save!
    end

    def update_due_date
      organization.update_attributes!(cop_due_on: extended_due_date, active: true)
    end

end