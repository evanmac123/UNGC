class GraceLetterForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :grace_letter, :presenter, :params

  delegate  :id,
            :title,
            :organization_id,
            :errors,
            :editable?,
            to: :grace_letter
  delegate  :grace_period,
            :due_on,
            :language_id,
            :cop_file,
            to: :presenter

  validate :verify_elligible_to_submit
  validate :verify_has_one_file

  def initialize(args={})
    @organization = args.fetch(:organization)
    @params = args.fetch(:params, {})
    @grace_letter = args[:grace_letter]
  end

  def grace_letter
    @grace_letter ||= GraceLetter.new(organization: organization)
  end

  def presenter
    @presenter ||= GraceLetterPresenter.new(grace_letter, nil)
  end

  def persisted?
    false
  end

  def save
    grace_letter.attributes = params.merge(organization:organization)
    valid? && grace_letter.save
  end

  def verify_has_one_file
    unless presenter.has_file?
      errors.add :grace_letter, 'Please select a PDF file for upload.'
    end
  end

  def verify_elligible_to_submit
    unless organization.can_submit_grace_letter?
      errors.add :grace_letter, "not elligible to submit a grace letter"
    end
  end
  alias_method :can_submit?, :verify_elligible_to_submit

end