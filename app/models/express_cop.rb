# == Schema Information
#
# Table name: communication_on_progresses
#
#  id                                  :integer          not null, primary key
#  organization_id                     :integer
#  title                               :string(255)
#  contact_info                        :string(255)
#  include_actions                     :boolean
#  include_measurement                 :boolean
#  use_indicators                      :boolean
#  cop_score_id                        :integer
#  use_gri                             :boolean
#  has_certification                   :boolean
#  notable_program                     :boolean
#  created_at                          :datetime
#  updated_at                          :datetime
#  description                         :text(65535)
#  state                               :string(255)
#  include_continued_support_statement :boolean
#  format                              :string(255)
#  references_human_rights             :boolean
#  references_labour                   :boolean
#  references_environment              :boolean
#  references_anti_corruption          :boolean
#  meets_advanced_criteria             :boolean
#  additional_questions                :boolean
#  starts_on                           :date
#  ends_on                             :date
#  method_shared                       :string(255)
#  differentiation                     :string(255)
#  references_business_peace           :boolean
#  references_water_mandate            :boolean
#  cop_type                            :string(255)
#  published_on                        :date
#  submission_status                   :integer          default(0), not null
#  endorses_ten_principles             :boolean
#  covers_issue_areas                  :boolean
#  measures_outcomes                   :boolean
#  type                                :string(255)      default("CommunicationOnProgress"), not null
#

class ExpressCop < CommunicationOnProgress
  validates :endorses_ten_principles, inclusion: {in: [true, false]}
  validates :covers_issue_areas, inclusion: {in: [true, false]}
  validates :measures_outcomes, inclusion: {in: [true, false]}
  validate  :organization_is_an_sme

  def differentiation_level
    if endorses_ten_principles && covers_issue_areas && measures_outcomes
      :active
    else
      :learner
    end
  end

  private

  def set_defaults
    # after_initialize
    super
    self.format ||= 'express'
    self.title ||= "Communication on Progress #{Time.zone.now.year}"
    self.starts_on ||= Date.today
    self.ends_on ||= Date.today + Organization::NEXT_BUSINESS_COP_YEAR.years
    self.published_on ||= Date.today
  end

  def organization_is_an_sme
    if organization.organization_type_id != OrganizationType.sme.id
      errors.add(:organization, "must be an SME")
    end
  end

end
