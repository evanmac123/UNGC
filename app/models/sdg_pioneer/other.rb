class SdgPioneer::Other < ActiveRecord::Base
  validates :organization_type, presence: true
  validates :submitter_name, presence: true, length: {maximum: 255}
  validates :submitter_place_of_work, presence: true, length: {maximum: 255}
  validates :submitter_job_title, presence: true, length: {maximum: 255}
  validates :submitter_email, presence: true, length: {maximum: 255}
  validates :submitter_phone, length: {maximum: 32}
  validates :sdg_pioneer_role, presence: true
  validates :nominee_name, presence: true, length: {maximum: 255}
  validates :nominee_work_place, presence: true, length: {maximum: 255}
  validates :nominee_title, presence: true, length: {maximum: 255}
  validates :nominee_email, presence: true, length: {maximum: 255}
  validates :nominee_phone, length: {maximum: 255}
  validates :why_nominate, presence: true, length: {maximum: 2750}
  validates :accepts_tou, presence: true

  enum sdg_pioneer_role: [
    :business_leaders_entrepreneurs,
    :change_makers
  ]
end
