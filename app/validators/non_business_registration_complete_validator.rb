class NonBusinessRegistrationCompleteValidator < NonBusinessRegistrationValidator
  def validate_callbacks
    super
    validate_mission_statement
  end

  private
    def validate_mission_statement
      if registration.mission_statement.blank? || registration.mission_statement.length < 1 || registration.mission_statement.length > 1000
        registration.errors.add :mission_statement, "should be between 1 and 1000 characters"
      end
    end
end
