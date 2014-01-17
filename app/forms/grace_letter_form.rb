class GraceLetterForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :organization

  delegate  :id,
            :title,
            :organization_id,
            :grace_period,
            :due_on,
            :language_id,
            :cop_file,
            to: :presenter

  delegate  :attachment,
            :attachment_type,
            to: :cop_file

  validates :attachment, presence: true
  validates :attachment_type, presence: true
  validates :language_id, presence: true

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
    valid? && application.submit(cop_file)
  end

  def persisted?
    false
  end

end
