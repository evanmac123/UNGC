FactoryGirl.define do
  factory :organization_type do
    name Faker::Company.name
    type_property OrganizationType::BUSINESS

    factory :sme_type do
      name OrganizationType::FILTERS[:sme]
      type_property OrganizationType::BUSINESS
    end

    factory :academic_type do
      name OrganizationType::FILTERS[:academia]
      type_property OrganizationType::NON_BUSINESS
    end

  end
end
