class SdgPioneer::Individual < ActiveRecord::Base
  validates :is_participant,            inclusion: [true, false]
  validates :is_nominated,              inclusion: [true, false]
  validates :nominating_organization,   presence: true, if: :is_nominated?
  validates :name,                      presence: true
  validates :email,                     presence: true
  validates :description_of_individual, presence: true, length: { maximum: 5500 }
  validates :other_relevant_info,       length: { maximum: 2750 }
  validates :accepts_tou,               presence: true
  validates :matching_sdgs,             presence: true
  validate  :validate_organization_name

  enum local_network_status: [
    :yes,
    :no,
    :not_available
  ]

  serialize :matching_sdgs, JSON

  validates :supporting_documents, length: {
              minimum: 1,
              maximum: 5,
              message: 'must have between 1 and 5 files' }

  has_many :supporting_documents,
              -> { where attachable_key: 'sdg_pioneer_individual_supporting_document'},
              class_name: 'UploadedFile',
              as: :attachable,
              dependent: :destroy

  def validate_organization_name
    if Organization.active.participants.where(name: self.organization_name).none?
      message = I18n.t('sdg_pioneer.validations.organization_name')
      self.errors.add :organization_name, message
    end
  end

  def uploaded_supporting_documents=(values)
    values.each do |attrs|
      self.supporting_documents.build(attrs)
    end
  end

  def matching_sdgs=(sdgs)
    super sdgs.reject(&:blank?).map(&:to_i)
  end

end
