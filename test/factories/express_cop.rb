FactoryBot.define do
  factory :express_cop do
    endorses_ten_principles false
    covers_issue_areas false
    measures_outcomes false
    organization

    after(:build) do |cop|
      sme = OrganizationType.sme || create(:sme_type)
      cop.organization.organization_type = sme
   end
  end
end
