# == Schema Information
#
# Table name: cop_attributes
#
#  id              :integer(4)      not null, primary key
#  cop_question_id :integer(4)
#  text            :string(255)
#  position        :integer(4)
#  created_at      :datetime
#  updated_at      :datetime
#

class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id
  belongs_to :cop_question
  
  default_scope :order => 'position'
  
  # TODO Move this method to the Importer, and make sure it is called after adding principles
  def self.add_records
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
      [:environment, true, "Does your COP provide information about activities and/or outcomes related to your company's participation in Caring for Climate?", Initiative.find_by_name("Caring For Climate").id, 4,
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
end
