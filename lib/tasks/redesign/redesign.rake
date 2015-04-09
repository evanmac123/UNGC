namespace :redesign do

  desc "Get the database ready for the redesign"
  task prepare: :environment do
    fix_principles_with_invalid_types
    create_topics
    create_issues
    add_explore_our_library
  end

  desc "Get your dev environment ready for redesign work"
  task prepare_dev: [
    :prepare,
    :randomize_content_types,
    :randomize_sectors,
    :randomize_issues,
    :randomize_topics
    ] do
      Searchable.index_resources
      Rake::Task["ts:index"].invoke
  end

  desc "Randomly assign content_types to Resources"
  task :randomize_content_types do
    Resource.find_each do |resource|
      resource.update_attribute :content_type, rand(3)
    end
  end

  desc "Randomly assign sectors to Resources"
  task :randomize_sectors do
    sectors = [
      "Oil Equipment, Services & Distribution",   # Oil & Gas
      "Chemicals",                                # Chemicals
      "Forestry & Paper",                         # Basic Resources
    ].map {|name| Sector.find_by!(name: name)}

    Resource.find_each do |resource|
      Tagging.create! resource: resource, sector: sectors[rand(sectors.length)]
    end
  end

  desc "Randomly assign issues to Resources"
  task :randomize_issues do
    issues = [
      "Principle 1", # in Social
      "Principle 2", # in Social
      "Principle 7", # in Environment
      "Principle 8", # in Environment
    ].map {|name| Issue.find_by!(name: name)}

    Resource.find_each do |resource|
      issue = issues[rand(issues.length)]
      Tagging.create! resource: resource, issue: issue
    end
  end

  desc "Randomly assign topics to Resources"
  task :randomize_topics do
    topics = [
      "Responsible Investment",     # in Financial Markets
      "Stock Markets",              # in Financial Markets
      "UN-Business Partnerships",   # in Partnerships
    ].map {|name| Topic.find_by!(name: name)}

    Resource.find_each do |resource|
      topic = topics[rand(topics.length)]
      Tagging.create! resource: resource, topic: topic
    end
  end

  private

  def fix_principles_with_invalid_types
    Principle.where(type:'').update_all(type: nil)
  end

  def create_issues
    areas = {
      'Social' => [
        "Principle 1",
        "Principle 2 ",
        "Principle 3",
        "Principle 4 ",
        "Principle 5 ",
        "Principle 6",
        "Child Labour",
        "Children's Rights",
        "Education",
        "Forced Labour",
        "Health",
        "Human Rights",
        "Human Trafficking",
        "Indigenous Peoples",
        "Labour",
        "Migrant Workers",
        "Persons with Disabilities",
        "Poverty",
        "Gender Equality",
        "Women's Empowerment",
      ],
      'Environment' => [
        "Principle 7",
        "Principle 8 ",
        "Principle 9 ",
        "Biodiversity",
        "Climate Change",
        "Energy",
        "Food and Agriculture",
        "Water and Sanitation",
      ],
      'Governance' => [
        "Principle 10",
        "Anti-Corruption",
        "Peace",
        "Rule of Law",
      ],
    }

    areas.each do |area_name, issues|
      area = IssueArea.where(name: area_name).first_or_create!
      issues.each do |issue_name|
        issue = Issue.where(name: issue_name).first_or_create!
        issue.issue_area = area
        issue.save!
      end
      area.save!
    end
  end

  def create_topics
    topics = {
      "Financial Markets" => [
        "Responsible Investment",
        "Stock Markets",
        "Private Sustainability Finance",
      ],
      "Supply Chain" => [

      ],
      "Partnerships" => [
        "UN-Business Partnerships",
        "Social Enterprise",
      ],
      "Management" => [
        "Board of Directors",
        "General Counsel",
      ],
      "Local Networks" => [

      ],
      "Leadership" => [

      ],
      "UN Goals and Issues" => [
        "Millennium Development Goals",
        "Post-2015 Agenda",
        "Sustainable Development Goals",
      ],
      "Reporting" => [
        "Communication on Progress",
        "Communication on Engagement",
        "Financial Reporting",
        "Integrated Reporting",
      ],
      "Management Education" => [

      ],
  }

    # make each existing principle into a top level topic
    # or create a new one.
    topics.each do |topic_name, children|
      # top level topics
      topic = Topic.where(name: topic_name).first_or_create!

      # one level of children
      children.each do |child_name|
        child = Topic.where(name: child_name).first_or_create!
        child.parent = topic
        child.save!
      end

      topic.save!
    end
  end

  def add_explore_our_library
    featured_content = Resource.all.shuffle.take(12).map &:id
    our_library = Redesign::Container.landing.where(slug: '/redesign/our-library').first_or_create!
    if our_library.public_payload.nil?
      our_library.public_payload = our_library.payloads.create! json_data: {featured: featured_content}.to_json
      our_library.save!
    end
  end

end
