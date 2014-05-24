class NonBusinessRegistrationValidator
  attr_reader :registration
  def initialize(registration)
    @registration = registration
  end

  def validate
    registration.errors.clear
    validate_callbacks
    !registration.errors.any?
  end

  def validate_callbacks
    validate_date
    validate_place
    validate_authority
  end

  private

    def validate_place
      if registration.place.blank?
        registration.errors.add :place, "of Registration can't be blank"
      end
    end

    def validate_authority
      if registration.authority.blank?
        registration.errors.add :authority, "can't be blank"
      end
    end

    def validate_date
      if registration.date.blank?
        registration.errors.add :date, "of Registration can't be blank"
      end
    end
end
