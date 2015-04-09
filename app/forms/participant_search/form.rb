class ParticipantSearch::Form
  include ActiveModel::Model

  attr_accessor :organization_type

  def page
    @page || 1
  end

  def per_page
    @per_page || 12
  end

  def order
    @order
  end

  def execute
    Organization.search(keywords, options)
  end

  private

  def keywords
    ''
  end

  def options
    options = {}

    if organization_type.present?
      options[:organization_type_id] = organization_type
    end

    {
      page: page || 1,
      per_page: per_page || 12,
      order: order,
      star: true,
      with: options
    }
  end

end
