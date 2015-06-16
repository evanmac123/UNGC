class Redesign::WhatYouCanDoForm < Redesign::FilterableForm
  include Virtus.model

  attribute :page,        Integer,        default: 1
  attribute :per_page,    Integer,        default: 123
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
    Redesign::Container.facets nil
  end

  def execute
    Redesign::Container.search nil, options
  end

  def options
    options = {
      issue_ids: issue_filter.effective_selection_set,
      topic_ids: topic_filter.effective_selection_set,
    }.reject { |_, value| value.blank? }

    {
      page: self.page || 1,
      per_page: self.per_page || 12,
      order: seed,
      star: true,
      with: options,
    }
  end

end
