class GraceLetterApplication
  GRACE_DAYS = 90

  attr_reader :contact, :organization

  def self.eligible?(user, organization)
    new(user, organization).valid?
  end

  def initialize(contact, organization)
    @contact = contact
    @organization = organization
  end

  def valid?
    [missing_perms?, delisted?, already_extended?].none?
  end

  def extended_due_date
    organization.cop_due_on + GRACE_DAYS.days
  end

  def submit(cop_file)
    if valid?
      letter = create_grace_letter(cop_file)
      update_due_date
      letter
    end
  end

  # needed to support ActiveModel::Errors
  def errors
    @errors ||= ActiveModel::Errors.new(self)
  end

  def read_attribute_for_validation(attr)
    send(attr)
  end

  def self.human_attribute_name(attr, options = {})
    attr
  end

  def self.lookup_ancestors
    [self]
  end

  private

    def missing_perms?
      # previously, the contact would delegate to organization's can_submit_grace_letter?
      # i suspect this is wrong and will need to change
    end

    def delisted?
      if organization.delisted?
        errors.add :organization, "Cannot submit a grace letter for a delisted organization"
      end
    end

    def already_extended?
      cops = organization.communication_on_progresses.approved
      if cops.any? && cops.first.is_grace_letter?
        errors.add :organization, "Cannot submit two grace letters in a row"
      end
    end

    def create_grace_letter(cop_file)
      GraceLetter.create!(
        organization: organization,
        starts_on: organization.cop_due_on,
        ends_on: extended_due_date,
        cop_files: [cop_file]
      )
    end

    def update_due_date
      organization.update_attributes(
        cop_due_on: extended_due_date,
        active: true
      )
    end

end