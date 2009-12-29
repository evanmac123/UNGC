module ImporterHooks
  include ImporterMapping
  # This module contains code that is executed after some files have been imported

  # runs after the organization import, pledge amount only exists
  # in the TEMP table/file
  def post_organization
    import_from_temp_table
    convert_organizations_to_local_networks
  end
  
  def post_contact
    assign_roles
    assign_network_managers
    assign_local_network_id
    assign_initiative_roles
  end
  
  def post_principle
    populate_principle_areas
    add_cop_questions if CopQuestion.count == 0
  end
  
  # Imports fields from R01_ORGANIZATION_TEMP.csv:
  #   pledge_amount & id
  def import_from_temp_table
    file = File.join(@data_folder, "R01_ORGANIZATION_TEMP.csv")
    CSV.foreach(file, :headers => :first_row) do |row|
      # get organization by name
      if o = Organization.find_by_name(row["ORG_NAME"])
        # import pledge
        pledge = row["PLEDGE_AMOUNT"]
        o.pledge_amount = pledge.to_i if pledge.to_i > 0
        # import id in TMP table
        old_tmp_id = row["ID"].to_i
        o.old_tmp_id = old_tmp_id if old_tmp_id.to_i > 0

        # import network_review state

        # R01_ORGANIZATION_TEMP.ORG_STATUS values
        # 0 = rejected 
        # 1 = new 
        # 2 = in review by Local Network 
        # 3 = accepted 
        
        
        # review_state = row["[ORG_STATUS]"]
        # if review_state.to_i == 2 
        #   o.state = 'network_review'
        #   o.network_review_on = row["[ORG_DATE_APPROVE]"]
        # end
        
        # if review_state.to_i == 0 
        #   o.state = 'rejected'
        #   o.rejected_on = row["[ORG_DATE_REJECT]"]
        # end
        
        # save the record
        o.save
      end
    end
  end
  
  def convert_organizations_to_local_networks
    get_local_network_organizations.each do |organization|
      name = organization.name.gsub(/GC Network - /, '')
      next if skip_extraction?(name)
      local_net = LocalNetwork.new( :name => name,
                                    :url  => organization.url )
      # 0-No network, 1-Network in Development, 2-Established
      if organization.country.network_type
        local_net.state = ['none', 'emerging', 'established'][organization.country.network_type]
      end
      # we now save the local network and assign the country
      local_net.save
      attach_countries_to_network(local_net, organization)
      # we no longer need the organization, we could "organization.delete" now
    end
  end
  
  def get_local_network_organizations
    OrganizationType.for_filter(:gc_networks).first.organizations.find(:all, :conditions => ["local_network = ? AND name LIKE ?", true, 'GC Network - %'])
  end
  
  def assign_roles
    file = File.join(@data_folder, "R12_XREF_R10_TR07.csv")
    # "ROLE_ID","CONTACT_ID","R01_ORG_NAME"
    CSV.foreach(file, :headers => :first_row) do |row|
      role_id = row['ROLE_ID']
      contact_id = row['CONTACT_ID']
      contact = Contact.find_by_old_id contact_id
      role = Role.find_by_old_id role_id
      if role && contact
        contact.roles << role
      else
        log "** [error] Could not assign role: #{row.inspect}"
      end
    end
  end
  
  def assign_initiative_roles
    # create roles
    roles = { :'1' => 'Caring for Climate Contact',
              :'2' => 'CEO Water Mandate - Endorsing Contact',
              :'4' => 'CEO Statement on Human Rights Contact',
              :'8' => 'CEO Water Mandate - Non-Endorsing Contact' }
    roles.values.each {|role| Role.find_or_create_by_name(role) }
    # "ID","INITIATIVE_ID","ORG_ID","CONTACT_ID"
    file = File.join(@data_folder, "R17_XREF_R10_TR13.csv")
    CSV.foreach(file, :headers => :first_row) do |row|
      role = Role.find_by_name roles[row['INITIATIVE_ID'].to_sym]
      contact = Contact.find_by_old_id row['CONTACT_ID']
      if role && contact
        contact.roles << role
      else
        log "** [error] Could not assign role: #{row.inspect} #{role} #{contact}"
      end
    end
  end

  def assign_network_managers
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    file = File.join(@data_folder, CONFIG[:country][:file])
    CSV.foreach(file, :headers => :first_row) do |row|
      manager = row['GC_COUNTRY_MANAGER']
      unless manager.blank?
        # get country, contact and network
        country = Country.find_by_code(row['COUNTRY_ID'])
        contact = Contact.first(:conditions => {:first_name => manager.split.first,
                                                :last_name  => manager.split.last})
        begin
          network = country.local_network.first
        rescue
          network = nil
        end
        if country && contact && network
          # get network and assign manager
          network.manager_id = contact.id
          network.save
        else
          log "** [minor error] Could not find contact: #{manager}" unless contact
          log "** [minor error] Could not find country: #{row['COUNTRY_ID']}" unless country
          log "** [minor error] Could not find network for: #{row['COUNTRY_ID']}" unless network
        end
      end
    end
  end
  
  def assign_local_network_id
    return unless LocalNetwork.count > 0
    get_local_network_organizations.each do |organization|
      puts "Working with #{organization.name} ##{organization.id}"
      if organization && contacts = organization.contacts and contacts.any?
        network = organization.country.local_network
        contacts.each do |contact|
          puts "  working with #{contact.name} ##{contact.id}"
          contact.update_attribute :local_network_id, network.id
          puts "  DONE!"
        end
      end
    end
  end
  
  def attach_countries_to_network(local_net, organization)
    organization.country.update_attribute :local_network_id, local_net.id
    countries = []
    if local_net.name =~ /Gulf States/
      countries = Country.find(:all, :conditions => ["name IN (?)", gulf_states])
    elsif local_net.name =~ /Nordic/
      countries = Country.find(:all, :conditions => ["name IN (?)", nordic_countries])
    end
    countries.each do |country|
      country.update_attribute :local_network_id, local_net.id
    end
  end
  
  def nordic_countries
    ['Denmark', 'Finland', 'Sweden', 'Norway', 'Iceland']
  end

  def gulf_states
    # Saudi Arabia seems mis-spelled?
    ['Bahrain', 'Kuwait', 'Oman', 'Qatar', 'Saudi Arabia', 'Saudia Arabia', 'United Arab Emirates']
  end

  def skip_extraction?(name)
    skip = nordic_countries + gulf_states
    skip.include?(name)
  end
  
  # Adds the default questions to be used in the COP form
  def add_cop_questions
    [ [:human_rights, :additional, "Commitment and policy. Does your COP contain information on the elements listed below? If yes, select one or more.", nil, 1, 
        ["Public commitment to respect and support human rights",
          "Reference to the Universal Declaration of Human Rights or other international instruments",
          "Reference to a formal human rights policy (e.g. in code of conduct)",
          "Differentiation between internal operations and external sphere of influence (complicity)",
          "Reflection on the relevance ('materiality') of human rights for your company (i.e. description of main human rights-related risks and opportunities)"]
      ],
      [:human_rights, :additional, "Implementation: Does your COP contain information on the activities listed below? If yes, select one or more.", nil, 2,
        ["Allocation of responsibilities and accountabilities within your organization",
          "Human rights risk and/or impact assessment",
          "External advice and stakeholder consultations",
          "Description of a grievance mechanism",
          "Internal and external educational outreach activities",
          "Training for employees",
          "Participation in human rights initiatives / collective action",
          "Inclusion of human rights issues in contracts with business partners",
          "Supplier audits (internal or external)",
          "Monitoring and evaluation"]
      ],      		
      [:human_rights, :additional, "Outcomes: Does your COP contain information on measurement of outcomes in the categories below? If yes, select one or more.", nil, 3,
        ["Qualitative outcomes", "Quantitative outcomes", "Definition of performance indicators", "Expected outcomes/targets"]
      ],
      [:human_rights, :additional, "Good practice: Does the COP reference good practices or illustrate specific examples in any of the following areas? If yes, select one or more.", nil, 4,
        ["Differentiation between internal operations and external sphere of influence (complicity)",
          "Public commitment to respect and support human rights",
          "Reference to a formal human rights policy (e.g. in code of conduct)",
          "Allocation of responsibilities and accountabilities within your organization",
          "Human rights risk and/or impact assessment",
          "External advice and stakeholder consultations",
          "Description of a grievance mechanism",
          "Internal and external educational outreach activities",
          "Training for employees",
          "Participation in human rights initiatives through collective action",
          "Inclusion of human rights issues in contracts with business partners",
          "Supplier audits (internal or external)",
          "Monitoring and evaluation"]
      ],      		
      [:human_rights, :additional, "Does your COP provide information about activities listed below that your company is undertaking to implement the Global Compact in any conflict-affected countries where you have operations?", nil, 5,
        ["Awareness raising", "Supplier due diligence", "Conflict-sensitive training for employees", "Participation in peace-building initiatives"]
      ],

      [:labour, :additional, "Commitment and policy: Does your COP contain information on the elements listed below?", nil, 1, 
        ["Reflection on the relevance ('materiality') of the labour principles (i.e. main risks and opportunities)",
          "Public commitment to uphold freedom of association and the right to collective bargaining",
          "Public commitment to eliminate forced and compulsory labour",
          "Public commitment to eliminate child labour",
          "Public commitment to eliminate discrimination in respect of employment and occupation",
          "Reference to labour issues covered in international instruments such as the International Labour Organization (ILO) MNE Declaration, ILO Core Conventions or OECD Guidelines",
          "Reference to a formal policy that addresses the four Global Compact principles on labour rights"        
        ]
      ],
      [:labour, :additional, "Implementation: Does your COP contain information on the activities listed below?", nil, 2, 
        ["Allocation of responsibilities and accountabilities within your organization",
          "Labor rights education, awareness and outreach",
          "Description of a grievance mechanisms",
          "Participation in industry association, framework agreement or other collective action",
          "Inclusion of minimal labour standards in contracts with business partners",
          "Description of internal audit mechanisms within direct (i.e. own and contractors')  operation",
          "Description of internal or external audit mechanisms within external sphere of influence (i.e. supply chain)"        
        ]
      ],
      [:labour, :additional, "Outcomes: Does your COP contain information on measurement of outcomes in the categories below?", nil, 3,
        ["Qualitative outcomes",
          "Quantitative outcomes",
          "Definition of performance indicators",
          "Expected outcomes/targets"
        ]
      ],
      [:labour, :additional, "Good practice: Does the COP reference good practices or illustrate specific examples in any of the following areas? If yes, select one or more.", nil, 4,
        ["Public commitment to uphold freedom of association and the right to collective bargaining",
          "Public commitment to eliminate forced and compulsory labour",
          "Public commitment to eliminate child labour",
          "Public commitment to eliminate discrimination in respect of employment and occupation",
          "Reference to a formal policy that addresses the four Global Compact principles on labour",
          "Allocation of responsibilities and accountabilities within your organization",
          "Labor rights education, awareness and outreach",
          "Description of a grievance mechanisms",
          "Participation in industry association, framework agreement or other collective action",
          "Inclusion of minimal labour standards in contracts with business partners",
          "Description of internal audit mechanisms within direct (i.e. own and contractors') operations",
          "Description of internal or third party audit mechanisms within external sphere of influence (i.e. supply chain)"        
        ]
      ],

      [:environment, :additional, "Commitment and policy: Does your COP contain information on the elements listed below?", nil, 1,
        ["Reflection on the relevance ('materiality') of environmental principles for your company (i.e. main environmental risks and opportunities)",
          "Public commitment to support a precautionary approach to environmental challenges",
          "Public commitment to undertake initiatives to promote greater environmental responsibility",
          "Public commitment to encourage the development and diffusion of environmentally friendly technologies",
          "Reference to a formal environmental policy",
          "Reference to the Rio Declaration on Environment and Development or other international instruments"        
        ]
      ],      
      [:environment, :additional, "Implementation: Does your COP contain information on the activities listed below?", nil, 2,
        ["Environmental risk and/or impact assessment",
          "Description of the company-wide environmental management system",
          "Allocation of responsibilities and accountabilities within your organization",
          "Awareness raising and educational outreach among employees and outside the organizations",
          "Eco-efficiency programs",
          "Life cycle assessment",
          "Participation in environmental initiatives (e.g. business associations)",
          "Inclusion of minimal environmental standards in contracts with business partners",
          "Description of internal audit or review mechanisms within direct operations to propose corrective action",
          "Description of audit mechanisms within external sphere of influence (contractors or subcontractors' operations)"
        ]
      ],
      [:environment, :additional, "Outcomes: Does your COP contain information on measurement of outcomes in the categories below?", nil, 3,
        ["Qualitative outcomes", "Quantitative outcomes", "Definition of performance indicators", "Expected outcomes/targets"]
      ],
      [:environment, :additional, "Good practice: Does the COP reference good practices or illustrate specific examples in any of the following areas? If yes, select one or more of the following items:", nil, 4,
        ["Public commitment to support a precautionary approach to environmental challenges",
          "Public commitment to undertake initiatives to promote greater environmental responsibility",
          "Public commitment to encourage the development and diffusion of environmentally friendly technologies",
          "Reference to a formal environmental policy",
          "Environmental risk and/or impact assessment",
          "Description of the company-wide environmental management system",
          "Allocation of responsibilities and accountabilities within the organization",
          "Awareness raising and educational outreach among employees and outside the organizations",
          "Eco-efficiency programs",
          "Life cycle assessment",
          "Participation in environmental initiatives (e.g. business associations)",
          "Inclusion of minimal environmental standards in contracts with business partners",
          "Description of internal audit or review mechanisms within direct operations to propose corrective action",
          "Description of audit mechanisms within external sphere of influence (contractors or subcontractors' operations)"
        ]
      ],
      [:environment, :additional, "Does your COP provide information on your company's activities related to carbon and climate change?", nil, 5,
        ["Activities aimed at improving the energy efficiency of products, services and processes",
          "Engagement in public policy",
          "Working collaboratively with peers and along the value-chain",
          "Data on carbon footprint",
          "Expected outcomes such as CO2 emission targets"
        ]
      ],
      [:environment, :additional, "Does your COP provide information about the following six elements related to water policies and management?", nil, 6,
        ["Activities and/or outcomes related to water usage in direct operations",
          "Activities and/or outcomes related to water usage in the supply chain",
          "Activities and/or outcomes related to participation in collective action on the issue of water",
          "Activities and/or outcomes related to public policy on the issue of water",
          "Activities and/or outcomes related to community engagement on the issue of water",
          "Activities and/or outcomes related to transparency"
        ]
      ],

      [:anti_corruption, :additional, "Commitment and policy: Does your COP contain information on the elements listed below?", nil, 1,
        ["Reflection on the relevance ('materiality') of corruption (i.e. balanced view of main risks and opportunities)",
        "Publicly stated commitment to work against corruption in all its forms, including bribery and extortion",
        "Commitment to be compliant with all relevant laws, including anti-corruption laws",
        "Publicly stated formal policy of zero-tolerance' of corruption",
        "Statement of support for international and regional legal frameworks, such as the UN Convention against Corruption (U.N.C.A.C)",
        "Carrying out risk assessment of potential areas of corruption",
        "Detailed policies for high risk areas of corruption",
        "Policy on anti-corruption regarding business partners"
        ]
      ],
      [:anti_corruption, :additional, "Implementation: Does your COP contain information on the activities listed below?", nil, 2,
        ["Translation of the anti-corruption commitment into actions",
          "Support by the organization's leadership to anti-corruption",
          "Communication and training on the anti-corruption commitment for all employees",
          "Internal checks-and balances to ensure consistency with anti-corruption commitment",
          "Monitoring and improvement processes",
          "Actions taken to encourage business partners to implement anti-corruption commitments",
          "Management responsibility and accountability for implementation of the anti-corruption commitment or policy",
          "Human Resources procedures supporting the anti-corruption commitment or policy",
          "Communications ('whistle-blowing') channels and follow up mechanisms for reporting concerns or seeking advice",
          "Internal accounting and auditing procedures related to anti-corruption",
          "Participation in voluntary anti-corruption initiatives"
        ]
      ],
      [:anti_corruption, :additional, "Outcomes: Does your COP contain information on measurement of outcomes in the categories below?", nil, 3,
        ["Qualitative outcomes", "Quantitative outcomes", "Definition of performance indicators", "Expected outcomes/targets"]
      ],
      [:anti_corruption, :additional, "Monitoring: Does your company's COP describe monitoring and improvement processes? If yes, does your COP contain information on measurement of outcomes in the categories below?", nil, 4,
        ["Leadership review of monitoring and improvement results", "Dealing with incidents", "Public legal cases regarding corruption", "Use of external assurance of anti-corruption programs"]
      ],
      
      [nil, :additional, "Does your COP contain information on the partners involved in your partnership project undertaken in support of broader United Nations goals?", nil, 1,
        ["With United Nations", "With NGOs", "With academia", "With other organizations"]
      ],
      [nil, :additional, "Does your COP contain information on the evaluation or an impact measurement of the partnership project?", nil, 2,
        ["Evaluation", "Evaluation using the Global Compact's Partnership Assessment Tool", "Impact measurement"]
      ],

      [nil, :mandatory, "Does your COP use the Global Reporting (GRI) framework?", nil, 1,
        ["No",
          "GRI G2 or GRI G3 frameworks with unknown application level",
          "GRI G3 - application level C",
          "GRI G3 - application level C+",
          "GRI G3 - application level B",
          "GRI G3 - application level B+",
          "GRI G3 - application level A",
          "GRI G3 - application level A+"
        ]
      ],
      [nil, :mandatory, "Does your COP contain information on the following elements?", nil, 2,
        ["Description of your company and its business activities (e.g. company profile,)",
          "Definition of boundary of COP (e.g. subsidiaries, joint ventures, subcontractors etc.)",
          "Description of how your company engages with stakeholder on the Global Compact issue areas",
          "Description of how the COP is shared with your company's stakeholders"
        ]
      ],
      
      [nil, :notable, "Does the statement of continued support to the Global Compact refer to major achievements in implementing the principles?", nil, 1,
        [""]
      ],
      [nil, :notable, "Does the statement of continued support to the Global Compact describe how your company actively supports the initiative (i.e. participation in UNGC events/Local networks and/or public interviews/speeches)?", nil, 2,
        [""]
      ],
      [nil, :notable, "Are your practical actions adequately described to allow readers to learn from your experience and replicate your approach (e.g. no bullet point or check-box descriptions)?", nil, 3,
        [""]
      ],
      [nil, :notable, "Does the COP outline specific actions your company has planned for the next year(s)?", nil, 4,
        [""]
      ],
      [nil, :notable, "Does the COP describe performance for several years, allowing the readers to check progress year on year?", nil, 5,
        [""]
      ],
      [nil, :notable, "Is your performance compared to peer companies or the industry/sector average?", nil, 6,
        [""]
      ],
      [nil, :notable, "Does your COP present positive and negative aspects of your performance to enable a reasoned assessment of overall performance?", nil, 7,
        [""]
      ],
      [nil, :notable, "Does your COP attempt to analyse the link between your outcomes and financial performance?", nil, 8,
        [""]
      ],
      [nil, :notable, "Is information made available in a manner that is understandable and accessible to stakeholders using the report (i.e. graphs, tables, diagrams, definitions)?", nil, 9,
        [""]
      ],
      [nil, :notable, "Is your COP third-party verified?", nil, 10,
        ["No",
          "Yes, using AA1000 Assurance Standard",
          "Yes, using ISAE 3000 framework.",
          "Yes, verified by a multi-stakeholder panel.",
          "Yes, peer reviewed by Global Compact Local Network.",
          "Yes, through other form of external verification."
        ]
      ]
      
    ].each do |record|
      principle_area_id = record.first.nil? ? nil : PrincipleArea.send(record.first).id
      question = CopQuestion.create(:principle_area_id => principle_area_id,
                                    :grouping          => record.second.to_s,
                                    :text              => record.third,
                                    :initiative_id     => record.fourth,
                                    :position          => record.fifth)
      record.sixth.each_with_index do |attribute, i|
        question.cop_attributes.create(:text => attribute, :position => i)
      end
    end
  end
  
  def populate_principle_areas
    [
      'Human Rights',
      'Labour',
      'Environment',
      'Anti-Corruption'
    ].each do |string|
      p = PrincipleArea.find_by_name(string) or PrincipleArea.create(:name => string)
    end
  end
end