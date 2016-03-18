class SdgPioneer::Individual < ActiveRecord::Base
  validates :is_nominated,              inclusion: [true, false]
  validates :nominating_organization,   presence: true, if: :is_nominated?
  validates :nominating_individual,     presence: true, if: :is_nominated?
  validates :name,                      presence: true
  validates :title,                     presence: true
  validates :email,                     presence: true
  validates :organization_name,         presence: true
  validates :is_participant,            inclusion: [true, false]
  validate :validate_country_name
  validates :website_url,               presence: true
  validates :description_of_individual, presence: true, length: { maximum: 5500 }
  validates :supporting_documents,      length: { minimum: 1, maximum: 5 }
  validates :matching_sdgs,             presence: true
  validates :other_relevant_info,       length: { maximum: 2750 }
  validates :accepts_tou,               presence: true

  enum local_network_status: [
    :yes,
    :no,
    :not_available
  ]

  serialize :matching_sdgs, JSON

  has_many :supporting_documents,
              -> { where attachable_key: 'sdg_pioneer_individual_supporting_document'},
              class_name: 'UploadedFile',
              as: :attachable,
              dependent: :destroy

  def validate_country_name
    if Country.where(name: self.country_name).none?
      message = I18n.t('sdg_pioneer.validations.country_name')
      self.errors.add :country_name, message
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

  def matching_sdg_names
    SustainableDevelopmentGoal.where(id: matching_sdgs).pluck(:name).join(", ")
  end

end
