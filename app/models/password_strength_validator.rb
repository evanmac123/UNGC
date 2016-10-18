class PasswordStrengthValidator < ActiveModel::Validator
  LOWERCASE = /[a-z]/.freeze
  UPPERCASE = /[A-Z]/.freeze
  DIGIT = /\d/.freeze

  def validate(record)
    password = record.password

    unless password =~ LOWERCASE
      record.errors[:password] << 'must have at least 1 lower case letter'
    end

    unless password =~ UPPERCASE
      record.errors[:password] << 'must have at least 1 upper case letter'
    end

    unless password =~ DIGIT
      record.errors[:password] << 'must have at least 1 digit'
    end

    if password =~ Regexp.new(record.email)
      record.errors[:password] << 'must not contain your email'
    end

    if password =~ Regexp.new(record.username)
      record.errors[:password] << 'must not contain your username'
    end

  end

end
