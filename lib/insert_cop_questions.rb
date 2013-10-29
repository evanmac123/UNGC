# rails runner 'InsertCopQuestions.new.run' -e production

class InsertCopQuestions
  def run

    # Academic #

    question = CopQuestion.create(
      text: "The COE contains a description of the practical actions that the organization has taken to promote the Global Compact and its principles through at least one of the following activities.",
      position: 1,
      grouping: 'academic',
      year: 2013
    )

    attributes = [
      "Incorporate the Global Compact principles into internal operations and communicate progress following the COE requirements (required)",
      "Deliver education on topics related to the Global Compact",
      "Conduct applied research and thought leadership in relation to the Global Compact",
      "Disseminate the Global Compact principles",
      "Provide support to UN Global Compact business participants in their own sustainability implementation and disclosure efforts",
      "Lend capacity to Global Compact Local Networks and / or the Global Compact Office"
      ]

    add_attributes(question, attributes)

    # Business Association #

    question = CopQuestion.create(
      text: "The COE contains a description of the practical actions that the organization has taken to support the Global Compact and to engage with the initiative.",
      position: 1,
      grouping: 'business_association',
      year: 2013
    )

    attributes = [
      "Attracting new participants to the UN Global Compact through their outreach efforts and awareness raising",
      "Organizing learning and dialogue events, workshops and training for their members on the UN Global Compact and specific topics relevant to corporate sustainability",
      "Providing their expertise and/or the voice of their members to Global Compact working groups and special initiatives.",
      "Engaging their members in collective action efforts on Global Compact-related issues",
      "Hosting the secretariat for a Global Compact Local Network",
      "Host the secretariat for Global Compact Local Networks"
      ]

    add_attributes(question, attributes)

    # Cities #

    question = CopQuestion.create(
      text: "The COE contains a description of the practical actions that the organization has taken to support the Global Compact and to engage with the initiative.",
      position: 1,
      grouping: 'city',
      year: 2013
    )

    attributes = [
      "Signatory City",
      "Reporting City",
      "Innovating City"
      ]

    add_attributes(question, attributes)

    # Civil Society #

    question = CopQuestion.create(
      text: "The COE contains a description of the practical actions that the organization has taken to support the Global Compact and to engage with the initiative.",
      position: 1,
      grouping: 'ngo',
      year: 2013
    )

    attributes = [
      "Engage with Global Compact Local Networks",
      "Join and/or propose partnership projects on corporate sustainability",
      "Engage companies in Global Compact-related issues",
      "Join and/or support special initiatives and work streams",
      "Provide commentary to companies on Communications on Progress",
      "Participate in Global Compact global, and local events"
      ]

      add_attributes(question, attributes)

    # Labour #

      question = CopQuestion.create(
        text: "The COE contains a description of the practical actions that the organization has taken to support the Global Compact and to engage with the initiative.",
        position: 1,
        grouping: 'labour',
        year: 2013
      )

      attributes = [
        "Build dialogue with companies and NGOs involved in the Global Compact",
        "Participate in Global Compact Local Networks",
        "Examine company performance and rights on sustainability issues"
      ]

      add_attributes(question, attributes)

    # Public Sector Organization #

      question = CopQuestion.create(
        text: "The COE contains a description of the practical actions that the organization has taken to support the Global Compact and to engage with the initiative.",
        position: 1,
        grouping: 'public',
        year: 2013
      )

      attributes = [
        "Participate in Global Compact Local Networks",
        "Join and/or propose partnership projects",
        "Internalize the Global Compact and engage companies",
        "Join and/or support special initiatives and work streams",
        "Participate in global, regional, and local events"
      ]

      add_attributes(question, attributes)

  end

  def delete_questions
    CopQuestion.where("grouping in ('academic', 'business_association', 'city', 'labour', 'ngo', 'public')").each {|q| q.destroy}
  end

  private

  def add_attributes(question, attributes)
    attributes.each_with_index do |a, index|
      CopAttribute.create(cop_question_id: question.id, text: a, position: index + 1)
    end
    # add other open text response question
    position = question.cop_attributes.count + 1
    CopAttribute.create(cop_question_id: question.id, text: "Other actions to support the Global Compact and to engage with the initiative", position: position, open: true)
    puts "#{question.text}"
  end

end
