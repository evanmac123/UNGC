# bundle exec rails runner 'InsertWepsCopQuestions.new.run' -e production

class InsertWepsCopQuestions
  def run

    delete_questions
    weps_initiative_id = Initiative.for_filter(:weps).first.id

    # Question 1

    question = CopQuestion.create(
      text: "The COP describes policies and practices related to supporting women's empowerment and advancing gender equality in the workplace",
      position: 1,
      grouping: 'additional',
      initiative_id: weps_initiative_id,
      year: 2014
    )

    attributes = [
      "Achieving and maintaining gender equality in senior management and board positions",
      "Achieving and maintaining gender equality in middle management positions ",
      "Equal pay for work of equal value",
      "Flexible work options",
      "Access to child and dependent care ",
      "Support for pregnant women and those returning from maternity leave",
      "Recruitment and retention, including training and development, of female employees",
      "Gender-specific health and safety issues",
      "Gender-based violence and harassment",
      "Education and training opportunities for women workers",
      "Creating and maintaining workplace awareness of gender equality and, inclusion and non-discrimination for all workers",
      "Mentoring and sponsorship opportunities for women workers"
      ]

    add_attributes(question, attributes)

    # Question 2

    question = CopQuestion.create(
      text: "The COP describes policies and practices related to supporting women's empowerment and advancing gender equality in the marketplace",
      position: 2,
      grouping: 'additional',
      initiative_id: weps_initiative_id,
      year: 2014
    )

    attributes = [
      "Supplier diversity programme",
      "Composition of supplier base by sex",
      "Support for women business owners and women entrepreneurs ",
      "Supplier monitoring and engagement on women's empowerment and gender equality including promotion of the Women's Empowerment Principles to suppliers",
      "Gender-sensitive marketing",
      "Gender-sensitive product and service development"
      ]

    add_attributes(question, attributes)

    # Question 3

    question = CopQuestion.create(
      text: "The COP describes policies and practices related to supporting women's empowerment and advancing gender equality in the community",
      position: 3,
      grouping: 'additional',
      initiative_id: weps_initiative_id,
      year: 2014
    )

    attributes = [
      "Designing community stakeholder engagements that are free of gender discrimination/stereotyping and sensitive to gender issues",
      "Gender impact assessments or consideration of gender-related impacts as part of its social and/or human rights impact assessments",
      "Ensuring female beneficiaries of community programmes",
      "Community initiatives specifically targeted at the empowerment of women and girls",
      "Strategies to ensure that community investment projects and programmes (including economic, social and environmental) positively impact women and girls",
      "Strategies to ensure that community investment projects and programmes (including economic, social and environmental) include the full participation of women and girls"
    ]

    add_attributes(question, attributes)

    # Question 4

    question = CopQuestion.create(
      text: "The COP contains or refers to sex-disaggregated data",
      position: 4,
      grouping: 'additional',
      initiative_id: weps_initiative_id,
      year: 2014
    )

    attributes = [
      "Achieving and maintaining gender equality in senior management and board positions",
      "Achieving and maintaining gender equality in middle management positions",
      "Equal pay for work of equal value",
      "Flexible work options",
      "Access to child and dependent care",
      "Support for pregnant women and those returning from maternity leave",
      "Recruitment and retention, including training and development, of female employees",
      "Gender-specific health and safety issues",
      "Gender-based violence and harassment",
      "Education and training opportunities for women workers",
      "Creating and maintaining workplace awareness of gender equality and, inclusion and non-discrimination for all workers",
      "Mentoring and sponsorship opportunities for women workers"
    ]

      add_attributes(question, attributes)

  end

  def delete_questions
    weps_initiative_id = Initiative.for_filter(:weps).first.id
    CopQuestion.where("initiative_id = #{weps_initiative_id}").each {|q| q.destroy}
  end

  private

  def add_attributes(question, attributes)
    attributes.each_with_index do |a, index|
      CopAttribute.create(cop_question_id: question.id, text: a, position: index + 1)
    end
    
    # same three attributes for all questions
    
    position = question.cop_attributes.count + 1
    CopAttribute.create(cop_question_id: question.id, text: "No practice for this criterion has been reported", position: position, open: false)
    
    position = question.cop_attributes.count + 1
    CopAttribute.create(cop_question_id: question.id, text: "Other established or emerging best practices", hint: "Specify in under 255 characters, including spaces. Alternatively, indicate if your COP does not address this but explains the reason for omission (e.g., topic deemed immaterial, legal prohibitions, privacy, competitive advantage).", position: position, open: true)
    
    position = question.cop_attributes.count + 1
    CopAttribute.create(cop_question_id: question.id, text: "Any relevant policies, procedures, and activities that the company plans to undertake by its next COP to address this area, including goals, timelines, metrics, and responsible staff", hint: "This option is for companies that have not yet begun to implement, but transparently and thoroughly disclose future plans to progress in this area in their COP", position: position, open: false)

  end

end
