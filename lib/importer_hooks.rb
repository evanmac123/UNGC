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
    [ [:human_rights, false, "Does the COP explain how your company determined that human rights are not relevant to its business or the communities in which it operates?", nil, 1,
        [""]
      ],
      [:human_rights, false, "Does the COP make explicit reference to planned policies and/or activities related to human rights?", nil, 2,
        [""]
      ],
      [:human_rights, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on human rights?", nil, 1, 
        ["Reflection on the relevance ('materiality') of human rights for your company", "Public commitment to respect and support human rights",
          "Reference to the Universal Declaration of Human Rights", "Formal human rights policy (e.g. in code of conduct)"]
      ],
      [:human_rights, true, "Implementation: Does the COP explain how human rights issues are managed and/or what activities your company is undertaking?", nil, 2,
        ["Allocation of responsibilities and accountabilities", "Human rights risk and/or impact assessment",
          "Grievance mechanism", "Internal and external communication", "Training for employees",
          "Participation in human rights initiatives / collective action", "Inclusion of human rights issues in contracts with business partners",
          "Supplier audits", "Monitoring and evaluation", "Other"]
      ],
      [:human_rights, true, "Outcomes: Does the COP contain information on outcomes of your human right policies and activities?", nil, 3,
        ["Qualitative outcomes", "Quantitative outcomes using defined indicators", "Expected outcomes/targets"]
      ],

      [:labour, false, "Does the COP explain how your company determined labour issues (freedom of association and right to collective bargaining; forced and compulsory labour; child labour; non-discrimination) are not relevant for its business or the communities in which it operates?", nil, 1,
        [""]
      ],
      [:labour, false, "Does the COP make explicit reference to planned policies and/or activities related to labour issues?", nil, 2,
        [""]
      ],
      [:labour, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on the labour principles?", nil, 1, 
        ["Reflection on the relevance ('materiality') of the labour principles for your company",
          "Public commitment to uphold freedom of association and the right to collective bargaining",
          "Public commitment to eliminate forced and compulsory labour",
          "Public commitment to eliminate child labour",
          "Public commitment to eliminate discrimination in respect of employment and occupation",
          "Reference to the International Labour Organization (ILO) Core Conventions",
          "Formal policy that addresses the labour principles (e.g. in code of conduct)"
        ]
      ],
      [:labour, true, "Implementation: Does the COP explain how the labour principles are managed and/or what activities your company is undertaking?", nil, 2, 
        ["Allocation of responsibilities and accountabilities",
          "Internal and external communication",
          "Training for employees",
          "Participation in labour initiatives / collective action",
          "Inclusion of labour issues in contracts with business partners",
          "Supplier audits",
          "Monitoring and evaluation",
          "Other"
        ]
      ],
      [:labour, true, "Outcomes: Does the COP contain information on outcomes of your labour policies and activities?", nil, 3,
        ["Qualitative outcomes (e.g. operations identified as having significant risk for labour incidents)",
          "Quantitative outcomes using defined indicators (e.g. percentage of employees covered by collective bargaining agreements; )",
          "Expected outcomes/targets"
        ]
      ],
      
      [:environment, false, "Does the COP explain how your company determined environmental issues are not relevant for its business or the communities in which it operates?", nil, 1,
        [""]
      ],
      [:environment, false, "Does the COP make explicit reference to planned policies and/or activities related to labour issues?", nil, 2,
        [""]
      ],
      [:environment, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on the environmental principles?", nil, 1,
        ["Reflection on the relevance ('materiality') of the labour principles for your company",
          "Public commitment to support a precautionary approach to environmental challenges",
          "Public commitment to undertake initiatives to promote greater environmental responsibility",
          "Public commitment to encourage the development and diffusion of environmentally friendly technologies",
          "Reference to the Rio Declaration on Environment and Development",
          "Formal environmental policy"
        ]
      ],
      [:environment, true, "Implementation: Does the COP explain how environmental issues are managed and/or what activities your company is undertaking?", nil, 2,
        ["Environmental risk and/or impact assessment",
          "Environmental management system",
          "Allocation of responsibilities and accountabilities",
          "Awareness raising",
          "Eco-efficiency programs",
          "Life cycle assessment",
          "Participation in environmental initiatives",
          "Inclusion of environmental issues in contracts with business partners",
          "Monitoring and evaluation",
          "Other"
        ]
      ],
      [:environment, true, "Outcomes: Does the COP contain information on outcomes of your environmental policies and activities?", nil, 3,
        ["Qualitative outcomes",
          "Quantitative outcomes using defined indicators",
          "Expected outcomes/targets"
        ]
      ],
      [:environment, true, "Does your COP provide information about activities and/or outcomes related to your company's participation in Caring for Climate?", Initiative.find_by_name("Caring For Climate").try(:id), 4,
        ["Activities aimed at improving the energy efficiency of products, services and processes",
          "Engagement in public policy",
          "Working collaboratively with peers and along the value-chain",
          "Data on carbon footprint",
          "Expected outcomes such as CO2 emission targets"
        ]
      ],
      
      [:anti_corruption, false, "Does the COP explain how your company determined that corruption is not relevant to its business or the communities in which it operates?", nil, 1,
        [""]
      ],
      [:anti_corruption, false, "Does the COP make explicit reference to planned policies and/or activities related to corruption?", nil, 2,
        [""]
      ],
      [:anti_corruption, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on the environmental principles?", nil, 1,
        ["Reflection on the relevance ('materiality') of corruption for your company",
          "Publicly stated commitment to zero-tolerance of corruption",
          "Commitment to be compliant with all laws relevant to corruption",
          "Formal anti-corruption policy (e.g. in code of conduct)",
          "Statement of support for international and regional legal frameworks, such as the UN Convention Against Corruption"
        ]
      ],
      [:anti_corruption, true, "Implementation: Does the COP explain how environmental issues are managed and/or what activities your company is undertaking?", nil, 2,
        ["Identification of corruption risks within your company's business",
          "Implementation of an anti-corruption program, such as standards and procedures, allocation of responsibilities, or sanctions",
          "Support by the organization's leadership to anti-corruption",
          "Communication of and training on the anti-corruption commitment to all employees",
          "Internal checks-and-balances to ensure consistency with anti-corruption commitment",
          "Whistle blowing and other communication channels for reporting concerns or seeking advice and follow up mechanism",
          "Communications and actions taken to encourage business partners to implement anti-corruption commitments",
          "Participation in voluntary anti-corruption initiatives / collective action",
          "Monitoring and improvement processes",
          "Other"
        ]
      ],
      [:anti_corruption, true, "Outcomes: Does the COP contain information on outcomes of your anti-corruption policies and activities?", nil, 3,
        ["Qualitative outcomes (e.g. public legal cases regarding corruption; actions taken in response to incidents of corruption)",
          "Quantitative outcomes using defined indicators (e.g. percentage and total number of business units analyzed for risks related to corruption)",
          "Expected outcomes/targets"
        ]
      ],
    ].each do |record|
      question = CopQuestion.create(:principle_area_id => PrincipleArea.send(record.first).id,
                                    :area_selected     => record.second,
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