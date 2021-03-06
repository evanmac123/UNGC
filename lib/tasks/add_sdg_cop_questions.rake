namespace :cop do

  desc 'Add the 2 new SDG Questions'
  task :create_sdg_cop_questions => :environment do
    CopQuestion.transaction do
      create_sdg_cop_questions
    end
  end

  def create_sdg_cop_questions
    q1 = CopQuestion.create!(
      year: 2016,
      grouping: :sdgs,
      position: 1,
      text: 'Which of the following Sustainable Development Goals (SDGs) do the activities described in your COP address? [Select all that apply]'
    )
    puts q1.text

    [
      'SDG 1: End poverty in all its forms everywhere',
      'SDG 2: End hunger, achieve food security and improved nutrition and promote sustainable agriculture',
      'SDG 3: Ensure healthy lives and promote well-being for all at all ages',
      'SDG 4: Ensure inclusive and equitable quality education and promote lifelong learning opportunities for all',
      'SDG 5: Achieve gender equality and empower all women and girls',
      'SDG 6: Ensure availability and sustainable management of water and sanitation for all',
      'SDG 7: Ensure access to affordable, reliable, sustainable and modern energy for all',
      'SDG 8: Promote sustained, inclusive and sustainable economic growth, full and productive employment and decent work for all',
      'SDG 9: Build resilient infrastructure, promote inclusive and sustainable industrialization and foster innovation',
      'SDG 10: Reduce inequality within and among countries',
      'SDG 11: Make cities and human settlements inclusive, safe, resilient and sustainable',
      'SDG 12: Ensure sustainable consumption and production patterns',
      'SDG 13: Take urgent action to combat climate change and its impacts',
      'SDG 14: Conserve and sustainably use the oceans, seas and marine resources for sustainable development',
      'SDG 15: Protect, restore and promote sustainable use of terrestrial ecosystems, sustainably manage forests, combat desertification, and halt and reverse land degradation and halt biodiversity loss',
      'SDG 16: Promote peaceful and inclusive societies for sustainable development, provide access to justice for all and build effective, accountable and inclusive institutions at all levels',
      'SDG 17: Strengthen the means of implementation and revitalize the global partnership for sustainable development',
    ].each_with_index do |text, index|
      attr = q1.cop_attributes.create!(
        text: text,
        position: index+1,
      )
      puts "  #{attr.text}"
    end


    q2 = CopQuestion.create!(
      year: 2016,
      grouping: :sdgs,
      position: 2,
      text: 'With respect to your company’s actions to advance the Sustainable Development Goals (SDGs), the COP describes: [Select all that apply]'
    )

    puts q2.text

    q2attributes = [
      ["Opportunities and responsibilities that one or more SDGs represent to our business",
        "E.g., new growth opportunities; risk profiles; improved trust among stakeholders; strengthened license to operate; reduced legal, reputational and other business risks; resilience to costs or requirements imposed by future legislation."],
      ["Where the company’s priorities lie with respect to one or more SDGs",
        "Conducting an assessment on the current and potential, positive and negative impacts that your business activities have on the SDGs throughout the value chain can help you identify your company’s priorities."],
      ["Goals and indicators set by our company with respect to one or more SDGs",
        "Setting specific, measurable and time-bound sustainability goals helps foster shared priorities and drive performance. To do this: Define scope of goals and select KPIs; define baseline and select goal type; set level of ambition; announce commitment to SDGs; select indicators and collect data."],
      ["How one or more SDGs are integrated into the company’s business model",
        "Integrating sustainability has the potential to transform all aspects of the company’s core business, including its product and service offering, customer segments, supply chain management, choice and use of raw materials, transport and distribution networks and product end-of-life.  It involves anchoring sustainability goals within the business up to the board level, embedding sustainability across all functions, and engaging in partnerships."],
      ["The (expected) outcomes and impact of your company’s activities related to the SDGs",
        "Example:  For a food company that sells nutritionally balanced breakfasts and lunches to primary schools, an output is the number of meals served.  An outcome is the rate of malnutrition among children served. Impact is the company’s contribution to SDG Target 2.1, “end hunger and ensure access by all people, in particular the poor and people in vulnerable situations, including infants, to safe, nutritious and sufficient food all year round.”"],
      ["If the companies' activities related to the SDGs are undertaken in collaboration with other stakeholders",
       "E.g., United Nations agencies, civil society, governments, other companies"],
    ]
    q2attributes.each_with_index do |text_and_hint, index|
      text, hint = text_and_hint
      attr = q2.cop_attributes.create!(
        text: text,
        hint: hint,
        position: index+1
      )
      puts "  #{attr.text}"
    end

    attr = q2.cop_attributes.create!(
      text: "Other established or emerging best practices",
      hint: "Please use the text box below to publicly share any other best practices. 255 characters or less, including spaces.",
      position: q2attributes.count + 1,
      open: true,
    )
    puts "  #{attr.text}"
  end
end
