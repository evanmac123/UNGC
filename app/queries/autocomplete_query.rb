class AutocompleteQuery

  def initialize(model)
    @model = model
  end

  def search(search_term)
    json(search_or_empty(search_term))
  end

  protected

  def do_search(search_term)
    @model.select(:id, :name)
          .order(:name)
          .where("name like ?", "%#{search_term}%")
  end

  private

  def json(items)
    items.map do |i|
      {
      id: i.id,
      label: i.name,
      value: i.name,
      }
    end
  end

  def search_or_empty(search_term, minimum_characters = 2)
    return @model.none if search_term.blank? || search_term.length < minimum_characters

    do_search(search_term).limit(5)
  end

end
