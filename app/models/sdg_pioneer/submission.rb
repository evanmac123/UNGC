class SdgPioneer::Submission < ActiveRecord::Base
  validates :is_nominated,                  inclusion: [true, false]
  validates :nominating_organization,       presence: true, if: :is_nominated?
  validates :nominating_individual,         presence: true, if: :is_nominated?
  validates :contact_person_name,           presence: true
  validates :contact_person_title,          presence: true
  validates :contact_person_email,          presence: true
  validates :organization_name,             presence: true
  validates :local_business_name,           length: { maximum: 255 }
  validates :is_participant,                inclusion: [true, false]
  validate :validate_country_name
  validates :website_url,                   presence: true
  validates :local_network_status,          presence: true
  validates :positive_outcomes,             presence: true, length: { maximum: 2750 }
  validates :positive_outcome_attachments,  length: { minimum: 1, maximum: 5,}
  validates :matching_sdgs,                 presence: true
  validates :other_relevant_info,           length: { maximum: 2750 }
  validates :accepts_tou,                   presence: true

  has_many :positive_outcome_attachments,
              -> { where attachable_key: 'positive_outcome'},
              class_name: 'UploadedFile',
              as: :attachable,
              dependent: :destroy

  enum local_network_status: [
    :yes,
    :no,
    :not_available
  ]

  serialize :matching_sdgs, JSON

  def uploaded_positive_outcome_attachments=(values)
    values.each do |attrs|
      self.positive_outcome_attachments.build(attrs)
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
