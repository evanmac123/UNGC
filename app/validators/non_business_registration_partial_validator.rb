class NonBusinessRegistrationPartialValidator < NonBusinessRegistrationValidator

  def initialize(registration, legal_status_id)
    super(registration)
    @legal_status_id = legal_status_id
  end

  def validate_callbacks
    super
    validate_legal_status
  end

  private

    def validate_legal_status
      if @legal_status_id.blank? && registration.number.blank?
        registration.errors.add :number, "can't be blank"
      end
    end
end
