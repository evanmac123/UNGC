class SdgPioneer::Submission < ActiveRecord::Base
  validates :pioneer_type,                presence: true
  validates :global_goals_activity,       presence: true, length: { maximum: 2750 }
  validates :matching_sdgs,               presence: true
  validates :name,                        presence: true
  validates :title,                       presence: true
  validates :email,                       presence: true
  validates :phone,                       presence: true
  validates :organization_name,           presence: true
  validates :organization_name_matched,   inclusion: [true, false]
  validate :validate_country_name
  validates :reason_for_being,            presence: true, length: { maximum: 2750 }
  validates :accepts_tou,                 inclusion: [true, false]

  has_many :supporting_document_attachments,
              -> { where attachable_key: 'supporting_document'},
              class_name: 'UploadedFile',
              as: :attachable,
              dependent: :destroy

  enum pioneer_type: [
    :local_business_leader,
    :local_change_maker,
  ]

  serialize :matching_sdgs, JSON

  def uploaded_supporting_document_attachments=(values)
    values.each do |attrs|
      self.supporting_document_attachments.build(attrs)
    end
  end

  def matching_sdgs=(sdgs)
    super sdgs.reject(&:blank?).map(&:to_i)
  end

  def validate_country_name
    if Country.where(name: self.country_name).none?
      message = I18n.t('sdg_pioneer.validations.country_name')
      self.errors.add :country_name, message
    end
  end

  def matching_sdg_names
    SustainableDevelopmentGoal.where(id: matching_sdgs).pluck(:name).join(", ")
  end

end
