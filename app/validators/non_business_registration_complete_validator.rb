class NonBusinessRegistrationCompleteValidator < NonBusinessRegistrationValidator
  def validate_callbacks
    super
    validate_mission_statement
    validate_legal_status
  end

  private
    def validate_mission_statement
      if registration.mission_statement.blank? || registration.mission_statement.length < 1 || registration.mission_statement.length > 1000
        registration.errors.add :mission_statement, "should be between 1 and 1000 characters"
      end
    end

    def validate_legal_status
      return true if registration.organization.nil?
      o = registration.organization.reload # HACK to go around rails sloppy relations
      if o.legal_status.blank? && registration.number.blank?
        registration.errors.add :number, "should be present or a legal status should be added"
      end
    end
end
