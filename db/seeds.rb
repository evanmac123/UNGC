# Create roles
roles = [
  "Highest Level Executive",
  "Contact Point",
  "Financial Contact",
  "General Contact",
  "Network Contact Person",
  "Local Network Guest",
  "Local Network Manager",
  "Local Network Executive Director",
  "Local Network Board Chair",
  "Network Report Recipient",
  "Network Representative",
  "Annual Survey Contact",
  "Website Editor",
  "Participant Relationship Manager",
  "Integrity Manager",
  "Integrity Team Member",
  "Action Platform Manager",
  "Academy",
]
roles.each do |name|
  Role.find_or_create_by!(name: name, description: name)
end

# OrganizationTypes
organization_types = [["Academic", OrganizationType::NON_BUSINESS],
 ["Business Association Global", OrganizationType::NON_BUSINESS],
 ["Business Association Local", OrganizationType::NON_BUSINESS],
 ["City", OrganizationType::NON_BUSINESS],
 ["Company", OrganizationType::BUSINESS],
 ["Foundation", OrganizationType::NON_BUSINESS],
 ["Labour Global", OrganizationType::NON_BUSINESS],
 ["Labour Local", OrganizationType::NON_BUSINESS],
 ["Micro Enterprise", OrganizationType::OTHER],
 ["NGO Global", OrganizationType::NON_BUSINESS],
 ["NGO Local", OrganizationType::NON_BUSINESS],
 ["Public Sector Organization", OrganizationType::NON_BUSINESS],
 ["SME", OrganizationType::BUSINESS],
 ["Initiative Signatory", OrganizationType::OTHER]]
organization_types.each do |(name, type)|
  OrganizationType.find_or_create_by!(name: name, type_property: type)
end

# Languages
languages = [
  "English",
  "French",
]
languages.each do |name|
  Language.find_or_create_by!(name: name)
end

# PrincipleAreas
principle_areas = [
  "Human Rights",
  "Labour",
  "Environment",
  "Anti-Corruption",
]
principle_areas.each do |name|
  PrincipleArea.find_or_create_by!(name: name)
end

# Sectors
# Sector.all.pluck(:name, :icb_number, :id, :parent_id, :preserved)
sectors = [["Not Applicable", nil, nil, false],
 ["Other", nil, nil, true],
 ["Diversified", nil, "Other", true],
 ["Oil & Gas", "0500", nil, false],
 ["Oil & Gas Producers", "0530", "Oil & Gas", false],
 ["Oil Equipment, Services & Distribution", "0570", "Oil & Gas", false],
 ["Alternative Energy", "0580", "Oil & Gas", false],
 ["Chemicals", "1300", nil, false],
 ["Chemicals", "1350", "Chemicals", false],
 ["Basic Resources", "1700", nil, false],
 ["Forestry & Paper", "1730", "Basic Resources", false],
 ["Industrial Metals & Mining", "1750", "Basic Resources", false],
 ["Mining", "1770", "Basic Resources", false],
 ["Construction & Materials", "2300", nil, false],
 ["Construction & Materials", "2350", "Construction & Materials", false],
 ["Industrial Goods & Services", "2700", nil, false],
 ["Aerospace & Defense", "2710", "Industrial Goods & Services", false],
 ["General Industrials", "2720", "Industrial Goods & Services", false],
 ["Electronic & Electrical Equipment", "2730", "Industrial Goods & Services", false],
 ["Industrial Engineering", "2750", "Industrial Goods & Services", false],
 ["Industrial Transportation", "2770", "Industrial Goods & Services", false],
 ["Support Services", "2790", "Industrial Goods & Services", false],
 ["Automobiles & Parts", "3300", nil, false],
 ["Automobiles & Parts", "3350", "Automobiles & Parts", false],
 ["Food & Beverage", "3500", nil, false],
 ["Beverages", "3530", "Food & Beverage", false],
 ["Food Producers", "3570", "Food & Beverage", false],
 ["Personal & Household Goods", "3700", nil, false],
 ["Household Goods & Home Construction", "3720", "Personal & Household Goods", false],
 ["Leisure Goods", "3740", "Personal & Household Goods", false],
 ["Personal Goods", "3760", "Personal & Household Goods", false],
 ["Tobacco", "3780", "Personal & Household Goods", false],
 ["Health Care", "4500", nil, false],
 ["Health Care Equipment & Services", "4530", "Health Care", false],
 ["Pharmaceuticals & Biotechnology", "4570", "Health Care", false],
 ["Retail", "5300", nil, false],
 ["Food & Drug Retailers", "5330", "Retail", false],
 ["General Retailers", "5370", "Retail", false],
 ["Media", "5500", nil, false],
 ["Media", "5550", "Media", false],
 ["Travel & Leisure", "5700", nil, false],
 ["Travel & Leisure", "5750", "Travel & Leisure", false],
 ["Telecommunications", "6500", nil, false],
 ["Fixed Line Telecommunications", "6530", "Telecommunications", false],
 ["Mobile Telecommunications", "6570", "Telecommunications", false],
 ["Utilities", "7500", nil, false],
 ["Electricity", "7530", "Utilities", false],
 ["Gas, Water & Multiutilities", "7570", "Utilities", false],
 ["Banks", "8300", nil, false],
 ["Banks", "8350", "Banks", false],
 ["Insurance", "8500", nil, false],
 ["Nonlife Insurance", "8530", "Insurance", false],
 ["Life Insurance", "8570", "Insurance", false],
 ["Real Estate", "8600", nil, false],
 ["Real Estate Investment & Services", "8630", "Real Estate", false],
 ["Real Estate Investment Trusts", "8670", "Real Estate", false],
 ["Financial Services", "8700", nil, false],
 ["Financial Services", "8770", "Financial Services", false],
 ["Equity Investment Instruments", "8980", "Financial Services", false],
 ["Nonequity Investment Instruments", "8990", "Financial Services", false],
 ["Technology", "9500", nil, false],
 ["Software & Computer Services", "9530", "Technology", false],
 ["Technology Hardware & Equipment", "9570", "Technology", false]]
sectors.each do |(name, icb_number, parent_name, preserved)|
  parent = Sector.find_by(name: parent_name, parent_id: nil) unless parent_name.blank?
  Sector.find_by(name: name, parent: parent) ||
      Sector.create!(name: name, icb_number: icb_number, preserved: preserved, parent: parent)
end

# Issues
# Issue.pluck(:id, :name, :type, :parent_id)
issues = [["Social", nil],
 ["Principle 1", "Social"],
 ["Principle 2 ", "Social"],
 ["Principle 3", "Social"],
 ["Principle 4 ", "Social"],
 ["Principle 5 ", "Social"],
 ["Principle 6", "Social"],
 ["Child Labour", "Social"],
 ["Children's Rights", "Social"],
 ["Education", "Social"],
 ["Forced Labour", "Social"],
 ["Health", "Social"],
 ["Human Rights", "Social"],
 ["Human Trafficking", "Social"],
 ["Indigenous Peoples", "Social"],
 ["Labour", "Social"],
 ["Migrant Workers", "Social"],
 ["Persons with Disabilities", "Social"],
 ["Poverty", "Social"],
 ["Gender Equality", "Social"],
 ["Women's Empowerment", "Social"],
 ["Environment", nil],
 ["Principle 7", "Environment"],
 ["Principle 8 ", "Environment"],
 ["Principle 9 ", "Environment"],
 ["Biodiversity", "Environment"],
 ["Climate Change", "Environment"],
 ["Energy", "Environment"],
 ["Food and Agriculture", "Environment"],
 ["Water and Sanitation", "Environment"],
 ["Governance", nil],
 ["Principle 10", "Governance"],
 ["Anti-Corruption", "Governance"],
 ["Peace", "Governance"],
 ["Rule of Law", "Governance"],
 ["Youth", "Social"]]
issues.each do |(name, parent_name)|
  parent = Issue.find_by(name: parent_name, parent_id: nil) unless parent_name.blank?
  Issue.find_or_create_by!(name: name, parent: parent)
end

# Topics
# Topic.pluck(:id, :name, :parent_id)
topics = [["Financial Markets", nil],
 ["Responsible Investment", "Financial Markets"],
 ["Stock Markets", "Financial Markets"],
 ["Private Sustainability Finance", "Financial Markets"],
 ["Supply Chain", nil],
 ["Partnerships", nil],
 ["UN-Business Partnerships", "Partnerships"],
 ["Social Enterprise", "Partnerships"],
 ["Management", nil],
 ["Board of Directors", "Management"],
 ["General Counsel", "Management"],
 ["Local Networks", nil],
 ["Leadership", nil],
 ["UN Goals and Issues", nil],
 ["Millennium Development Goals", "UN Goals and Issues"],
 ["Post-2015 Agenda", "UN Goals and Issues"],
 ["Sustainable Development Goals", "UN Goals and Issues"],
 ["Reporting", nil],
 ["Communication on Progress", "Reporting"],
 ["Communication on Engagement", "Reporting"],
 ["Financial Reporting", "Reporting"],
 ["Integrated Reporting", "Reporting"],
 ["Management Education", nil]]
topics.each do |(name, parent_name)|
  parent = Topic.find_by(name: parent_name, parent_id: nil) unless parent_name.blank?
  Topic.find_or_create_by!(name: name, parent: parent)
end

removal_reasons = [
  "Other",
  "Participant requested withdrawal",
  "Organization no longer exists",
  "Expelled due to failure to communicate progress",
  "Expelled due to failure to engage in dialogue",
  "Removed due to suspension or removal from the UN vendor list",
  "Other reason related to the Integrity Measures",
  "Merger or acquisition",
  "Transfer of commitment",
  "Consolidation of commitment under the parent company",
  "Non-responsive"]
removal_reasons.each do |description|
  RemovalReason.find_or_create_by!(description: description)
end

ungc = Organization.find_or_create_by!(name: "UNGC") do |organization|
  organization.organization_type = OrganizationType.for_filter(:civil_global).first
  organization.sector_id = Sector.not_applicable
  organization.participant = false
  organization.employees = 33
  organization.url = "http://unglobalcompact.org/"
  organization.active = false
  organization.state = "approved"
  organization.is_ft_500 = false
  organization.cop_state = "active"
end

Country.find_or_create_by!(name: 'United States of America') do |country|
  country.code = 'US'
  country.region = 'northern_america'
end

# Create a contact with the role of integrity manager
Contact.find_or_create_by!(last_name: "UNGC") do |contact|
  contact.organization_id = ungc.id,
  contact.roles << Role.integrity_manager
  contact.prefix = 'Mr'
  contact.first_name = 'Manager'
  contact.email = 'emailx34B@example.com'
  contact.job_title = 'Manager of Integrity'
  contact.address = '13344'
  contact.city = 'New York'
  contact.country = Country.first
  contact.phone = '2126553433'
end

# TODO ListingStatus
# TODO Exchanges

# Initiative.pluck(:id, :name, :active)
initiatives = [
  ["Anti-Corruption Working Group", true],
  ["Board Members", false],
  ["Business for Peace Expert Group", false],
  ["Business for Peace Signatories", true],
  ["Call to Action: Anti-Corruption and the Post-2015 Development Agenda", true],
  ["Carbon Pricing Champions", true],
  ["Caring For Climate", true],
  ["Caring for Climate (delisted signatories)", false],
  ["Caring for Climate (non-business)", true],
  ["CEO Letter on UNCAC Review Mechanism", false],
  ["CEO Statement on Human Rights", false],
  ["CEO Water Mandate", true],
  ["CEO Water Mandate (Non-Endorsing)", false],
  ["Child Labour Platform", true],
  ["Environmental Stewardship Group", false],
  ["Food and Agriculture Business Principles", false],
  ["Founding Companies", true],
  ["GC 100", true],
  ["Global Compact Board Programme", true],
  ["Global Compact LEAD", true],
  ["Global Framework Agreement (Labour)", true],
  ["Human Rights and Labour Working Group", true],
  ["Integrity Measures - Dialogue Facilitation", false],
  ["Leader's Summit 2013", false],
  ["Leaders Summit Champions - 2010", false],
  ["Prospective Organizations", false],
  ["Rio+20 Corporate Sustainability Forum - 2012", false],
  ["Social & Governance", false],
  ["Social Enterprise and Impact Investing Engagement", false],
  ["Supply Chain Advisory Group", true],
  ["WEPs Leadership Group", false],
  ["Women's Empowerment Principles", true],
  ["ZERO HUNGER CHALLENGE", false]
]
initiatives.each do |name, active|
  Initiative.find_by_name(name) || Initiative.create!(name: name, active: active)
end

ungc_name = DEFAULTS[:ungc_organization_name]
ungc = Organization.where(name: ungc_name).first_or_create
ungc.update!(
  organization_type: OrganizationType.find_by(name: "NGO Global"),
  participant: false,
  employees: 33
)

if false # disable for now
  # Create container/payloads that are required for the site to function
  # TODO There are many many pages missing currently, but they should be added.
  # TODO This code needs to be refactored and moved out of here

  def seed_page(file_path)
    path = Pathname.new(File.expand_path("./db/page_seeds#{file_path}.json"))
    document = JSON.parse(File.open(path).read)

    draft_payload_id = document.delete('draft_payload_id')
    draft_payload_attrs = document.delete('draft_payload')

    public_payload_id = document.delete('public_payload_id')
    public_payload_attrs = document.delete('public_payload')

    container = Container.find_by(id: document.fetch('id'))
    return container if container.present?

    Container.transaction do
      container = Container.create!(document)

      if draft_payload_id.present?
        payload = container.create_draft_payload!(
          id: draft_payload_id,
          container_id: container.id,
          json_data: draft_payload_attrs.to_json
        )
        container.draft_payload = payload
      end

      if public_payload_id.present?
        container.create_draft_payload!(
          id: public_payload_id,
          container_id: container.id,
          json_data: public_payload_attrs.to_json
        )
        container.public_payload = payload
      end

      container.save!
    end

    puts "Created seed page for #{file_path}"
    container
  end

  seed_page '/what-is-gc/our-work/sustainable-development/sdgpioneers'
end
