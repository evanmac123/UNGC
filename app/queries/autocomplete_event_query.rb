class AutocompleteEventQuery < AutocompleteQuery

  def initialize(relation=Event)
    super(Event)
  end

  protected

  def do_search(term)
    Event.select(:id, :title)
          .order(:title, :updated_at)
          .where("title like ?", "%#{term}%")
          .limit(5)
  end

  def json(items)
    items.map do |i|
      {
          id: i.id,
          label: i.title,
          value: i.title,
      }
    end
  end


end
