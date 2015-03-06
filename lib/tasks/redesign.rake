namespace :redesign do

  desc "Get the database ready for the redesign"
  task :prepare do
    fix_principles_with_invalid_types
    create_or_update_topics_taxonomy
    create_or_update_issue_taxonomy
  end

  private

  def fix_principles_with_invalid_types
    Principle.where(type:'').update_all(type: nil)
  end

  def create_or_update_issue_taxonomy
    principles = {
      "Human Rights" => [
        "Principle 1 - Businesses should support and respect the protection of internationally proclaimed human rights",
        "Principle 2 - Make sure that they are not complicit in human rights abuses",
        "Children's Rights",
        "Human Trafficking",
        "Indigenous Peoples",
        "Persons with Disabilities",
        "Women and Gender Equality",
      ],
      "Labour" => [
        "Principle 3 - Businesses should uphold freedom of association & effective recognition of the right to collective bargaining",
        "Principle 4 - The elimination of all forms of forced and compulsory labour",
        "Principle 5 - The effective abolition of child labour",
        "Principle 6 - Eliminate discrimination in respect of employment and occupation",
        "Child Labour",
        "Forced Labour",
        "Migrant Workers",
      ],
      "Environment" => [
        "Principle 7 - Businesses should support a precautionary approach to environmental challenges",
        "Principle 8 - Undertake initiatives to promote greater environmental responsibility",
        "Principle 9 - Encourage the development and diffusion of environmentally friendly technologies",
        "Climate Change",
        "Water Sustainability ",
        "Energy",
        "Biodiversity",
        "Environmental Stewardship",
        "Green Industry",
        "Food and Agriculture",
      ],
      "Anti-Corruption" => [
        "Principle 10 - Businesses should work against all forms of corruption, including extortion and bribery"
      ],
      "Strengthening Society" => [
        "Peace",
        "Poverty",
        "Education education ",
        "Social Enterprise & Impact Investing",
        "Rule of Law rule of law",
      ]
    }

    principles.each do |name, children|
      area = PrincipleArea.where(name: name).first_or_create!
      area.parent_id = nil

      children.each do |child_name|
        child = Principle.where(name: child_name).first_or_create!
        child.parent_id = area.id
        child.type = nil
        child.save!
      end

      area.save!
    end
  end

  def create_or_update_topics_taxonomy
    topics = {
      'Financial Markets' => [
          'Stock Markets'
      ],
      'Supply Chain Sustainability' => [],
      'Partnerships' => [
          'UN / Business Partnerships'
      ],
      'Management' => [],
      'Global Compact' => [],
      'Local Networks' => [],
      'Leadership' => [],
      'UN Goals and Issues' => [
          'Millennium Development Goals',
          'Post-2015 Agenda',
          'Sustainable Development Goals',
      ],
      'Government' => [],
      'Reporting' => [
          'Communication on Progress',
          'Communication on Engagement',
          'Financial Reporting',
          'Integrated Reporting',
      ],
      'Management Education' => [],
  }

    # make each existing principle into a top level topic
    # or create a new one.
    topics.each do |name, children|
      # top level topics
      topic = Principle.where(name: name).first_or_create!
      topic.parent_id = nil
      topic.type = 'Topic'

      # one level of children
      children.each do |child_name|
        child = Principle.where(name: child_name).first_or_create!
        child.parent_id = topic.id
        child.type = 'Topic'
        child.save!
      end

      topic.save!
    end
  end

end
