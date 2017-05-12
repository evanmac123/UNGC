# Create roles
roles = [
  "Highest Level Executive",
  "Contact Point",
  "Financial Contact",
  "General Contact",
  "Network Contact Person",
  "Local Network Guest",
  "Local Network Manager",
  "Network Report Recipient",
  "Network Representative",
  "Annual Survey Contact",
  "Website Editor",
  "Participant Relationship Manager",
  "Integrity Manager",
  "Integrity Team Member",
]
roles.each do |name|
  Role.find_or_create_by!(name: name, description: name)
end

# OrganizationTypes
organization_types = [["Academic", 1],
 ["Business Association Global", 1],
 ["Business Association Local", 1],
 ["City", 1],
 ["Company", 2],
 ["Foundation", 1],
 ["Labour Global", 1],
 ["Labour Local", 1],
 ["Micro Enterprise", 0],
 ["NGO Global", 1],
 ["NGO Local", 1],
 ["Public Sector Organization", 1],
 ["SME", 2],
 ["Initiative Signatory", 0]]
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
Sector.destroy_all
# Sector.all.pluck(:name, :icb_number, :id, :parent_id, :preserved)
sectors = [["Not Applicable", nil, 1, nil, false],
 ["Other", "", 71, nil, true],
 ["Diversified", "", 81, 71, true],
 ["Oil & Gas", "0500", 2, nil, false],
 ["Oil & Gas Producers", "0530", 23, 2, false],
 ["Oil Equipment, Services & Distribution", "0570", 21, 2, false],
 ["Alternative Energy", "0580", 22, 2, false],
 ["Chemicals", "1300", 3, nil, false],
 ["Chemicals", "1350", 24, 3, false],
 ["Basic Resources", "1700", 4, nil, false],
 ["Forestry & Paper", "1730", 26, 4, false],
 ["Industrial Metals & Mining", "1750", 25, 4, false],
 ["Mining", "1770", 27, 4, false],
 ["Construction & Materials", "2300", 5, nil, false],
 ["Construction & Materials", "2350", 28, 5, false],
 ["Industrial Goods & Services", "2700", 6, nil, false],
 ["Aerospace & Defense", "2710", 30, 6, false],
 ["General Industrials", "2720", 33, 6, false],
 ["Electronic & Electrical Equipment", "2730", 34, 6, false],
 ["Industrial Engineering", "2750", 31, 6, false],
 ["Industrial Transportation", "2770", 32, 6, false],
 ["Support Services", "2790", 29, 6, false],
 ["Automobiles & Parts", "3300", 7, nil, false],
 ["Automobiles & Parts", "3350", 35, 7, false],
 ["Food & Beverage", "3500", 8, nil, false],
 ["Beverages", "3530", 37, 8, false],
 ["Food Producers", "3570", 36, 8, false],
 ["Personal & Household Goods", "3700", 9, nil, false],
 ["Household Goods & Home Construction", "3720", 38, 9, false],
 ["Leisure Goods", "3740", 39, 9, false],
 ["Personal Goods", "3760", 40, 9, false],
 ["Tobacco", "3780", 41, 9, false],
 ["Health Care", "4500", 10, nil, false],
 ["Health Care Equipment & Services", "4530", 43, 10, false],
 ["Pharmaceuticals & Biotechnology", "4570", 42, 10, false],
 ["Retail", "5300", 11, nil, false],
 ["Food & Drug Retailers", "5330", 45, 11, false],
 ["General Retailers", "5370", 44, 11, false],
 ["Media", "5500", 12, nil, false],
 ["Media", "5550", 46, 12, false],
 ["Travel & Leisure", "5700", 13, nil, false],
 ["Travel & Leisure", "5750", 47, 13, false],
 ["Telecommunications", "6500", 14, nil, false],
 ["Fixed Line Telecommunications", "6530", 48, 14, false],
 ["Mobile Telecommunications", "6570", 49, 14, false],
 ["Utilities", "7500", 15, nil, false],
 ["Electricity", "7530", 50, 15, false],
 ["Gas, Water & Multiutilities", "7570", 51, 15, false],
 ["Banks", "8300", 16, nil, false],
 ["Banks", "8350", 52, 16, false],
 ["Insurance", "8500", 17, nil, false],
 ["Nonlife Insurance", "8530", 54, 17, false],
 ["Life Insurance", "8570", 53, 17, false],
 ["Real Estate", "8600", 18, nil, false],
 ["Real Estate Investment & Services", "8630", 56, 18, false],
 ["Real Estate Investment Trusts", "8670", 55, 18, false],
 ["Financial Services", "8700", 19, nil, false],
 ["Financial Services", "8770", 58, 19, false],
 ["Equity Investment Instruments", "8980", 57, 19, false],
 ["Nonequity Investment Instruments", "8990", 59, 19, false],
 ["Technology", "9500", 20, nil, false],
 ["Software & Computer Services", "9530", 60, 20, false],
 ["Technology Hardware & Equipment", "9570", 61, 20, false]]
sectors.each do |(name, icb_number, id, parent_id, preserved)|
  Sector.find_or_create_by!(
    id: id,
    name: name,
    icb_number: icb_number,
    parent_id: parent_id,
    preserved: preserved
  )
end

# Issues
# Issue.pluck(:id, :name, :type, :parent_id)
issues = [[1, "Social", nil, nil],
 [11, "Principle 1", nil, 1],
 [21, "Principle 2 ", nil, 1],
 [31, "Principle 3", nil, 1],
 [41, "Principle 4 ", nil, 1],
 [51, "Principle 5 ", nil, 1],
 [61, "Principle 6", nil, 1],
 [71, "Child Labour", nil, 1],
 [81, "Children's Rights", nil, 1],
 [91, "Education", nil, 1],
 [101, "Forced Labour", nil, 1],
 [111, "Health", nil, 1],
 [121, "Human Rights", nil, 1],
 [131, "Human Trafficking", nil, 1],
 [141, "Indigenous Peoples", nil, 1],
 [151, "Labour", nil, 1],
 [161, "Migrant Workers", nil, 1],
 [171, "Persons with Disabilities", nil, 1],
 [181, "Poverty", nil, 1],
 [191, "Gender Equality", nil, 1],
 [201, "Women's Empowerment", nil, 1],
 [211, "Environment", nil, nil],
 [221, "Principle 7", nil, 211],
 [231, "Principle 8 ", nil, 211],
 [241, "Principle 9 ", nil, 211],
 [251, "Biodiversity", nil, 211],
 [261, "Climate Change", nil, 211],
 [271, "Energy", nil, 211],
 [281, "Food and Agriculture", nil, 211],
 [291, "Water and Sanitation", nil, 211],
 [301, "Governance", nil, nil],
 [311, "Principle 10", nil, 301],
 [321, "Anti-Corruption", nil, 301],
 [331, "Peace", nil, 301],
 [341, "Rule of Law", nil, 301],
 [351, "Youth", nil, 1]]
issues.each do |(id, name, type, parent_id)|
  Issue.find_or_create_by!(
    id: id,
    name: name,
    type: type,
    parent_id: parent_id
  )
end

# Topics
# Topic.pluck(:id, :name, :parent_id)
topics = [[1, "Financial Markets", nil],
 [11, "Responsible Investment", 1],
 [21, "Stock Markets", 1],
 [31, "Private Sustainability Finance", 1],
 [41, "Supply Chain", nil],
 [51, "Partnerships", nil],
 [61, "UN-Business Partnerships", 51],
 [71, "Social Enterprise", 51],
 [81, "Management", nil],
 [91, "Board of Directors", 81],
 [101, "General Counsel", 81],
 [111, "Local Networks", nil],
 [121, "Leadership", nil],
 [131, "UN Goals and Issues", nil],
 [141, "Millennium Development Goals", 131],
 [151, "Post-2015 Agenda", 131],
 [161, "Sustainable Development Goals", 131],
 [171, "Reporting", nil],
 [181, "Communication on Progress", 171],
 [191, "Communication on Engagement", 171],
 [201, "Financial Reporting", 171],
 [211, "Integrated Reporting", 171],
 [221, "Management Education", nil]]
topics.each do |(id, name, parent_id)|
  Topic.find_or_create_by!(
    id: id,
    name: name,
    parent_id: parent_id
  )
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
  [21, "Anti-Corruption Working Group", true],
  [131, "Board Members", false],
  [22, "Business for Peace Expert Group", false],
  [51, "Business for Peace Signatories", true],
  [181, "Call to Action: Anti-Corruption and the Post-2015 Development Agenda", true],
  [191, "Carbon Pricing Champions", true],
  [2, "Caring For Climate", true],
  [15, "Caring for Climate (delisted signatories)", false],
  [16, "Caring for Climate (non-business)", true],
  [5, "CEO Letter on UNCAC Review Mechanism", false],
  [4, "CEO Statement on Human Rights", false],
  [1, "CEO Water Mandate", true],
  [7, "CEO Water Mandate (Non-Endorsing)", false],
  [151, "Child Labour Platform", true],
  [14, "Environmental Stewardship Group", false],
  [91, "Food and Agriculture Business Principles", false],
  [13, "Founding Companies", true],
  [121, "GC 100", true],
  [171, "Global Compact Board Programme", true],
  [19, "Global Compact LEAD", true],
  [3, "Global Framework Agreement (Labour)", true],
  [11, "Human Rights and Labour Working Group", true],
  [161, "Integrity Measures - Dialogue Facilitation", false],
  [111, "Leader's Summit 2013", false],
  [12, "Leaders Summit Champions - 2010", false],
  [81, "Prospective Organizations", false],
  [101, "Rio+20 Corporate Sustainability Forum - 2012", false],
  [211, "Social & Governance", false],
  [71, "Social Enterprise and Impact Investing Engagement", false],
  [24, "Supply Chain Advisory Group", true],
  [201, "WEPs Leadership Group", false],
  [25, "Women's Empowerment Principles", true],
  [221, "ZERO HUNGER CHALLENGE", false]
]
initiatives.each do |id, name, active|
  initiative = Initiative.find_or_create_by!(id: id)
  initiative.update(name: name, active: active)
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
