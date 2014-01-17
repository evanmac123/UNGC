class GraceLetterForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization

  delegate  :id,
            :title,
            :organization_id,
            :errors,
            to: :grace_letter
  delegate  :grace_period,
            :due_on,
            :language_id,
            :cop_file,
            to: :presenter

  validate :verify_has_one_file

  def initialize(organization, grace_letter=nil, contact=nil)
    @organization = organization
    @grace_letter = grace_letter
    @contact = contact
  end

  def grace_letter
    @grace_letter ||= application.grace_letter
  end

  def presenter
    @presenter ||= GraceLetterPresenter.new(grace_letter, @contact)
  end

  def application
    @application ||= GraceLetterApplication.new(organization)
  end

  def submit(params)
    grace_letter.attributes = grace_letter.attributes.merge(params)
    application.grace_letter = grace_letter
    valid? && application.submit(grace_letter.cop_files.first)
  end

  def verify_has_one_file
    # this is wrong.
    unless presenter.has_file?
      errors.add :grace_letter, 'Please select a PDF file for upload.'
    end
  end

  def persisted?
    false
  end

end
