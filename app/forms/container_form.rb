class ContainerForm < FilterableForm
  include Virtus.model
  include FilterMacros

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []

  filter :issue
  filter :topic

  def initialize(params, seed, sphinx_scope:)
    super(params)
    @seed = seed
    @sphinx_scope = sphinx_scope
  end

  def facets
    sphinx_scope.facets ''
  end

  def execute
    sphinx_scope.search '', options
  end

  def options
    # TODO randomize the order
    # sphinx does not support rand() with a seed until 2.2.4
    {
      page: page,
      per_page: per_page,
      with: facet_options,
      order: 'rand()',
      rand_seed: seed,
    }
  end

  def facet_options
    {
      issue_ids: issue_filter.effective_selection_set,
      topic_ids: topic_filter.effective_selection_set,
    }.reject { |_, value| value.blank? }
  end

  private

  attr_reader :seed, :sphinx_scope

end
