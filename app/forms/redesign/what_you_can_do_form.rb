class Redesign::WhatYouCanDoForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 12
  attribute :issues,      Array[Integer], default: []
  attribute :topics,      Array[Integer], default: []

  filter :issue
  filter :topic

  attr_reader :seed
  def initialize(params, seed)
    super(params)
    @seed = seed
  end

  def facets
    Redesign::Container.actions.facets ''
  end

  def execute
    Redesign::Container.actions.search '', options
  end

  def options
    # TODO randomize the order
    # sphinx does not support rand() with a seed until 2.2.4
    {
      page: page,
      per_page: per_page,
      with: facet_options,
    }
  end

  def facet_options
    {
      issue_ids: issue_filter.effective_selection_set,
      topic_ids: topic_filter.effective_selection_set,
    }.reject { |_, value| value.blank? }
  end

end
