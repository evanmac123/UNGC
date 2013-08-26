module ResourcesHelper
  def languages_for_select(selected_language=nil)
    options_for_select(Language.all.map { |c| [c.name, c.id] }, selected: selected_language)
  end
end
