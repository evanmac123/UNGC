class BasicCopQuestionnaire
  attr_reader :questionnaire

  def self.create
    new.create_questionnaire
  end

  def create_questionnaire
    create_statement_of_support_question
    create_human_rights_questions
    create_labour_questions
    create_environment_questions
    create_anti_corruption_questions
    self
  end

  def question_count
    @_question_count ||= CopAttribute.count
  end

  private

  def create(*args)
    FactoryGirl.create(*args)
  end

  def create_statement_of_support_question
    support = create(:cop_question, grouping: :basic,
                     text: 'Statement of continued support by the Chief Executive Officer')
    create(:cop_attribute, cop_question: support,
           open: true, text: "Statement of the company's chief executive (CEO or equivalent) expressing continued support for the Global Compact and renewing the company's ongoing commitment to the initiative and its principles.")
  end

  def create_human_rights_questions
    hr_assessment_policy_and_goals = create(:cop_question, grouping: :basic,
                                            text: 'Assessment, policy and goals',
                                            principle_area: PrincipleArea.human_rights)
    create(:cop_attribute, cop_question: hr_assessment_policy_and_goals,
           open: true, text: "Description of the relevance of human rights for the company (i.e. human rights risk-assessment). Description of policies, public commitments and company goals on Human Rights.")

    hr_implementation = create(:cop_question, grouping: :basic,
                               text: 'Implementation',
                               principle_area: PrincipleArea.human_rights)

    create(:cop_attribute, cop_question: hr_implementation,
           open: true, text: "Description of concrete actions to implement Human Rights policies, address Human Rights risks and respond to Human Rights violations.")

    hr_measurement_of_outcomes = create(:cop_question, grouping: :basic,
                                        text: 'Measurement of outcomes',
                                        principle_area: PrincipleArea.human_rights)

    create(:cop_attribute, cop_question: hr_measurement_of_outcomes,
           open: true, text: "Description of how the company monitors and evaluates performance.")
  end

  def create_labour_questions
    lbr_assessment_policy_and_goals = create(:cop_question, grouping: :basic,
                                             text: 'Assessment, policy and goals',
                                             principle_area: PrincipleArea.labour)
    create(:cop_attribute, cop_question: lbr_assessment_policy_and_goals,
           open: true, text: "Description of the relevance of labour rights for the company (i.e. labour rights-related risks and opportunities). Description of policies, public commitments and company goals on labour.")
    lbr_implementation = create(:cop_question, grouping: :basic,
                                text: 'Implementation',
                                principle_area: PrincipleArea.labour)

    create(:cop_attribute, cop_question: lbr_implementation,

           open: true, text: "Description of concrete actions taken by the company to implement labour policies, address labour risks and respond to labour violations.")

    lbr_measurement_of_outcomes = create(:cop_question, grouping: :basic,
                                         text: 'Measurement of outcomes',
                                         principle_area: PrincipleArea.labour)

    create(:cop_attribute, cop_question: lbr_measurement_of_outcomes,
           open: true, text: "Description of how the company monitors and evaluates performance.")
  end

  def create_environment_questions
    env_assessment_policy_and_goals = create(:cop_question, grouping: :basic,
                                             text: 'Assessment, policy and goals',
                                             principle_area: PrincipleArea.environment)
    create(:cop_attribute, cop_question: env_assessment_policy_and_goals,
           open: true, text: "Description of the relevance of environmental protection for the company (i.e. environmental risks and opportunities). Description of policies, public commitments and company goals on environmental protection.")

    env_implementation = create(:cop_question, grouping: :basic,
                                text: 'Implementation',
                                principle_area: PrincipleArea.environment)

    create(:cop_attribute, cop_question: env_implementation,
           open: true, text: "Description of concrete actions to implement environmental policies, address environmental risks and respond to environmental incidents.")

    env_measurement_of_outcomes = create(:cop_question, grouping: :basic,
                                         text: 'Measurement of outcomes',
                                         principle_area: PrincipleArea.environment)

    create(:cop_attribute, cop_question: env_measurement_of_outcomes,
           open: true, text: "Description of how the company monitors and evaluates environmental performance.")
  end

  def create_anti_corruption_questions
    anti_corr_assessment_policy_and_goals = create(:cop_question, grouping: :basic,
                                                   text: 'Assessment, policy and goals',
                                                   principle_area: PrincipleArea.anti_corruption)
    create(:cop_attribute, cop_question: anti_corr_assessment_policy_and_goals,
           open: true, text: "Description of the relevance of anti-corruption for the company (i.e. anti-corruption rights-related risks and opportunities). Description of policies, public commitments and company goals on anti-corruption.")

    anti_corr_implementation = create(:cop_question, grouping: :basic,
                                      text: 'Implementation',
                                      principle_area: PrincipleArea.anti_corruption)

    create(:cop_attribute, cop_question: anti_corr_implementation,
           open: true, text: "Description of concrete actions to implement anti-corruption policies, address anti-corruption risks and respond to anti-corruption violations.")

    anti_corr_measurement_of_outcomes = create(:cop_question, grouping: :basic,
                                               text: 'Measurement of outcomes',
                                               principle_area: PrincipleArea.anti_corruption)

    create(:cop_attribute, cop_question: anti_corr_measurement_of_outcomes,
           open: true, text: "Description of how the company monitors and evaluates anti-corruption performance.")
  end

end
