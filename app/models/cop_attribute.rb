class CopAttribute < ActiveRecord::Base
  validates_presence_of :cop_question_id
  belongs_to :cop_question
  
  default_scope :order => 'position'
  
  # TODO Move this method to the Importer, and make sure it is called after adding principles
  def self.add_records
    [ [:human_rights, false, "Does the COP explain how your company determined that human rights are not relevant to its business or the communities in which it operates?", 1,
        [""]
      ],
      [:human_rights, false, "Does the COP make explicit reference to planned policies and/or activities related to human rights?", 2,
        [""]
      ],
      [:human_rights, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on human rights?", 1, 
        ["Reflection on the relevance ('materiality') of human rights for your company", "Public commitment to respect and support human rights",
          "Reference to the Universal Declaration of Human Rights", "Formal human rights policy (e.g. in code of conduct)"]
      ],
      [:human_rights, true, "Implementation: Does the COP explain how human rights issues are managed and/or what activities your company is undertaking?", 2,
        ["Allocation of responsibilities and accountabilities", "Human rights risk and/or impact assessment",
          "Grievance mechanism", "Internal and external communication", "Training for employees",
          "Participation in human rights initiatives / collective action", "Inclusion of human rights issues in contracts with business partners",
          "Supplier audits", "Monitoring and evaluation", "Other"]
      ],
      [:human_rights, true, "Outcomes: Does the COP contain information on outcomes of your human right policies and activities?", 3,
        ["Qualitative outcomes", "Quantitative outcomes using defined indicators", "Expected outcomes/targets"]
      ],

      [:labour, false, "Does the COP explain how your company determined labour issues (freedom of association and right to collective bargaining; forced and compulsory labour; child labour; non-discrimination) are not relevant for its business or the communities in which it operates?", 1,
        [""]
      ],
      [:labour, false, "Does the COP make explicit reference to planned policies and/or activities related to labour issues?", 2,
        [""]
      ],
      [:labour, true, "Commitment and policy: Does the COP make an explicit commitment or mention a policy document on the labour principles?", 1, 
        ["Reflection on the relevance ('materiality') of the labour principles for your company",
          "Public commitment to uphold freedom of association and the right to collective bargaining",
          "Public commitment to eliminate forced and compulsory labour",
          "Public commitment to eliminate child labour",
          "Public commitment to eliminate discrimination in respect of employment and occupation",
          "Reference to the International Labour Organization (ILO) Core Conventions",
          "Formal policy that addresses the labour principles (e.g. in code of conduct)"
        ]
      ],
      [:labour, true, "Implementation: Does the COP explain how the labour principles are managed and/or what activities your company is undertaking?", 2, 
        ["Allocation of responsibilities and accountabilities",
          "Internal and external communication",
          "Training for employees",
          "Participation in labour initiatives / collective action",
          "Inclusion of labour issues in contracts with business partners",
          "Supplier audits",
          "Monitoring and evaluation",
          "Other"
        ]
      ]
    ].each do |record|
      question = CopQuestion.create(:principle_area_id => PrincipleArea.send(record.first).id,
                                    :area_selected     => record.second,
                                    :text              => record.third,
                                    :position          => record.fourth)
      record.fifth.each_with_index do |attribute, i|
        question.cop_attributes.create(:text => attribute, :position => i)
      end
    end
  end
end
