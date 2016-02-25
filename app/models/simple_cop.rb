class SimpleCop < CommunicationOnProgress
  validates :endorses_ten_principles, inclusion: {in: [true, false]}
  validates :covers_issue_areas, inclusion: {in: [true, false]}
  validates :measures_outcomes, inclusion: {in: [true, false]}
  validate  :organization_is_an_sme

  after_initialize :set_defaults

  private

  def set_defaults
    self.format ||= 'simple'
    self.title ||= "Communication on Progress #{Time.zone.now.year}"
  end

  def organization_is_an_sme
    if organization.organization_type_id != OrganizationType.sme.id
      errors.add(:organization, "must be an SME")
    end
  end

end
