class ResourcePresenter < SimpleDelegator
  def content_types_for_select
    Resource.content_types.keys.map {|k| [k.humanize.titleize, k]}
  end

  def human_content_type
    if content_type.present?
      content_type.humanize.titleize
    else
      ''
    end
  end

  def topic_options
    selected_ids = self.topics.pluck(:id)
    Redesign::TopicHierarchy.new.map do |group, items|
      [group, items.map { |topic|
        selected = selected_ids.include?(topic.id)
        Filter.new(topic,  selected)
      }]
    end
  end

  def issue_options
    selected_ids = self.issues.pluck(:id)
    Redesign::IssueHierarchy.new.map do |group, items|
      [group, items.map { |issue|
        selected = selected_ids.include?(issue.id)
        Filter.new(issue,  selected)
      }]
    end
  end

  Filter = Struct.new(:model, :selected?) do

    def id
      model.id
    end

    def name
      model.name
    end

  end

end
