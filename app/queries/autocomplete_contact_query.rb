class AutocompleteContactQuery < AutocompleteQuery

  def initialize
    super(Contact)
  end

  protected

  def do_search(term)
    Contact.select(:id, :first_name, :last_name)
          .order(:first_name, :last_name)
          .where("concat(first_name, ' ', last_name) like ?", "%#{term}%")
          .limit(5)
  end

end
