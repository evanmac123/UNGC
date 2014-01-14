class GraceLetterForm < GraceLetterPresenter
  # extend ActiveModel::Naming
  # include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_reader :grace_letter

  delegate :organization_id, to: :grace_letter

  validates :organization_id, presence: true
  validates :files, length: {minimum: 1}
  accepts_nested_attributes_for :cop_files, :allow_destroy => true

  def initialize(grace_letter)
    @grace_letter = grace_letter
  end

  def grace_period
    Organization::COP_GRACE_PERIOD
  end

  def due_on
    (organization.cop_due_on + grace_period).to_date
  end

  def language_id
    @language_id ||= Language.for(:english).try(:id)
  end

  def cop_type
    CopFile::TYPES[:grace_letter]
  end

  def cop_file
    files.first || CopFile.new(:attachment_type => cop_type)
  end

  def persisted?
    false
  end

  def save
    if valid?
      persist!
      true
    else
      false
    end
  end

  private

    def cop
      grace_letter
    end

    def persist!
      raise "meow"
    end

end