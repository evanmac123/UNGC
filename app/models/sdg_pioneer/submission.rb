# == Schema Information
#
# Table name: sdg_pioneer_submissions
#
#  id                        :integer          not null, primary key
#  pioneer_type              :integer
#  global_goals_activity     :text(65535)
#  matching_sdgs             :string(255)
#  name                      :string(255)
#  title                     :string(255)
#  email                     :string(255)
#  phone                     :string(255)
#  organization_name         :string(255)
#  organization_name_matched :boolean          default(FALSE), not null
#  country_name              :string(255)
#  reason_for_being          :text(65535)
#  accepts_tou               :boolean          default(FALSE), not null
#  is_participant            :boolean
#  website_url               :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class SdgPioneer::Submission < ActiveRecord::Base
  before_create :set_pioneer_type

  validates :matching_sdgs,               presence: true
  validates :name,                        presence: true, length: { maximum: 255 }
  validates :title,                       presence: true, length: { maximum: 255 }
  validates :email,                       presence: true, length: { maximum: 255 }
  validates :phone,                       presence: true, length: { maximum: 255 }
  validates :organization_name,           presence: true, length: { maximum: 255 }
  validates :organization_name_matched,   inclusion: [true, false]
  validate :validate_country_name
  validates :company_success,            presence: true, length: { maximum: 500 }
  validates :innovative_sdgs,            presence: true, length: { maximum: 500 }
  validates :ten_principles,             presence: true, length: { maximum: 500 }
  validates :awareness_and_mobilize,     presence: true, length: { maximum: 500 }
  validates :accepts_tou,                 inclusion: [true, false]
  validates :supporting_documents,        length: { minimum: 1, maximmum: 12 }
  validates :website_url,                 length: { maximum: 255 }

  has_many :supporting_documents,
              -> { where attachable_key: 'supporting_document'},
              class_name: 'UploadedFile',
              as: :attachable,
              dependent: :destroy

  enum pioneer_type: [
    :local_business_leader,
    :local_change_maker,
    :business_leader
  ]

  serialize :matching_sdgs, JSON

  def uploaded_supporting_documents=(values)
    values.each do |attrs|
      self.supporting_documents.build(attrs)
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
    SustainableDevelopmentGoal.where(id: matching_sdgs).pluck(:name)
  end

  def set_pioneer_type
    self.pioneer_type ||= :business_leader
  end

end
