# == Schema Information
#
# Table name: sdg_pioneer_others
#
#  id                        :integer          not null, primary key
#  submitter_name            :string(255)
#  submitter_place_of_work   :string(255)
#  submitter_email           :string(255)
#  nominee_name              :string(255)
#  nominee_email             :string(255)
#  nominee_phone             :string(255)
#  nominee_work_place        :string(255)
#  organization_type         :string(255)
#  submitter_job_title       :string(255)
#  submitter_phone           :string(255)
#  accepts_tou               :boolean          default(FALSE), not null
#  nominee_title             :string(255)
#  why_nominate              :text(65535)
#  sdg_pioneer_role          :integer
#  emailed_at                :datetime
#  is_participant            :boolean
#  organization_name         :string(255)
#  organization_name_matched :boolean
#  created_at                :datetime
#  updated_at                :datetime
#

class SdgPioneer::Other < ActiveRecord::Base
  validates :submitter_name,            presence: true, length: {maximum: 255}
  validates :submitter_place_of_work,   presence: true, length: {maximum: 255}
  validates :submitter_job_title,       presence: true, length: {maximum: 255}
  validates :submitter_email,           presence: true, length: {maximum: 255}
  validates :submitter_phone,           length: {maximum: 32}
  validates :nominee_name,              presence: true, length: {maximum: 255}
  validates :nominee_work_place,        presence: true, length: {maximum: 255}
  validates :nominee_title,             presence: true, length: {maximum: 255}
  validates :nominee_email,             presence: true, length: {maximum: 255}
  validates :nominee_phone,             length: {maximum: 32}
  validates :why_nominate,              presence: true, length: {maximum: 1000}
  validates :organization_name,         presence: true, length: { maximum: 255 }
  validates :organization_name_matched, inclusion: [true, false]

  validates :accepts_tou,               presence: true

  enum sdg_pioneer_role: [
    :business_leaders_entrepreneurs,
    :change_makers
  ]
end
