class LibrarySearchForm < FilterableForm
  include Virtus.model
  include FilterMacros

  attribute :issue_areas,         Array[Integer], default: []
  attribute :issues,              Array[Integer], default: []
  attribute :topic_groups,        Array[Integer], default: []
  attribute :topics,              Array[Integer], default: []
  attribute :languages,           Array[Integer], default: []
  attribute :sector_groups,       Array[Integer], default: []
  attribute :sectors,             Array[Integer], default: []
  attribute :content_type,        String,         default: ''
  attribute :keywords,            String,         default: ''
  attribute :page,                Integer
  attribute :per_page,            Integer,        default: 12
  attribute :sort_field,          String,         default: 'year desc'

  filter :issue,      parent: :issue_areas
  filter :topic,      parent: :topic_groups
  filter :sector,     parent: :sector_groups
  filter :language

  attr_writer :search_scope

  def initialize(page = 1, params = {})
    super(params)
    self.page = page
  end

  def type_options
    @type_options ||= format_content_types
  end

  def sort_options
    @sort_options ||= [
      ["Date",          :date],
      ["Title (A-Z)",   :title_asc],
      ["Title (Z-A)",   :title_desc],
    ]
  end

  def disabled?
    active_filters.count >= 5
  end

  def options
    options = {
      issue_ids: issue_filter.effective_selection_set,
      topic_ids: topic_filter.effective_selection_set,
      language_ids: languages,
      sector_ids: sector_filter.effective_selection_set,
      content_type: content_type,
    }

    {
      indices: ['resource_new_core'],
      page: self.page || 1,
      per_page: self.per_page || 12,
      order: order,
      with: reject_blanks(options),
    }
  end

  def execute
    search_scope.search(escaped_keywords, options)
  end

  def escaped_keywords
    escape(keywords)
  end

  private

  def order
    case self.sort_field
    when 'date'
      'year desc'
    when 'title_asc'
      'title asc'
    when 'title_desc'
      'title desc'
    else
      'year desc'
    end
  end

  def format_content_types
    Resource.content_types
      .to_a
      .sort
      .map do |name, id|
        title = I18n.t("resources.types.#{name}")
        [title, id]
      end
  end

  def facets
    search_scope.facets('', {indices: ['resource_new_core']})
  end

  def search_scope
    @search_scope ||= Resource
  end

end
