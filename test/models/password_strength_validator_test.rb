require 'test_helper'

class PasswordStrengthValidatorTest < ActiveSupport::TestCase

  test "valid passwords are valid" do
    contact = build(:contact, password: 'f0Obar')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_empty contact.errors.full_messages
  end

  test "must have 1 lower case letter" do
    contact = build(:contact, password: 'UPPER123')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_includes contact.errors.full_messages, 'Password must have at least 1 lower case letter'
  end

  test "must have 1 upper case letter" do
    contact = build(:contact, password: 'lower123')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_includes contact.errors.full_messages, 'Password must have at least 1 upper case letter'
  end

  test "must have 1 digit" do
    contact = build(:contact, password: 'noDigits')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_includes contact.errors.full_messages, 'Password must have at least 1 digit'
  end

  test "must not contain their email" do
    contact = build(:contact,
                    email: 'bob@foo.org',
                    password: 'Secret123-bob@foo.org')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_includes contact.errors.full_messages, 'Password must not contain your email'
  end

  test "must not contain their username" do
    contact = build(:contact,
                    username: 'alice123',
                    password: 'Secret123-alice123')
    validator = PasswordStrengthValidator.new
    validator.validate(contact)
    assert_includes contact.errors.full_messages, 'Password must not contain your username'
  end

end
