class GraceLetterForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization, :grace_letter, :presenter, :params

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

  def initialize(organization, params={})
    @organization = organization
    @params = params
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
    grace_letter.save
  end

end