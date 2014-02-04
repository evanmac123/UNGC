class GraceLetterForm
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Rails.application.routes.url_helpers

  attr_reader :organization, :cop_file, :grace_letter
  attr_accessor :edit

  delegate  :attachment,
            :attachment_type,
            :language_id,
            to: :cop_file

  validates :attachment, presence: true
  validates :attachment_type, presence: true
  validates :language_id, presence: true

  def initialize(organization, grace_letter=nil)
    @organization = organization
    @grace_letter = grace_letter || GraceLetter.new(organization: organization)
  end

  def grace_period
    GraceLetterApplication::GRACE_DAYS
  end

  def due_on
    (organization.cop_due_on + grace_period.days).to_date
  end

  def cop_file
    @cop_file ||= grace_letter.cop_files.first || create_cop_file
  end

  def attachment_file_name
    cop_file.attachment_file_name
  end

  def attachment_url
    cop_file.attachment.url
  end

  def language_id
    cop_file.language_id
  end

  def has_file?
    grace_letter.cop_files.any?
  end

  def submit(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment]

    if valid?
      GraceLetterApplication.submit_for(organization, grace_letter)
    end
  end

  def update(params)
    cop_file.language_id = params[:language_id]
    cop_file.attachment = params[:attachment] if params.has_key?(:attachment)
    valid? && cop_file.save
  end

  def return_url
    if edit
      admin_organization_grace_letter_path(organization.id, grace_letter.id)
    else
      cop_introduction_path
    end
  end

  def persisted?
    false
  end

  private

    def create_cop_file
      grace_letter.cop_files.build(attachment_type: GraceLetter::TYPE)
    end

end
