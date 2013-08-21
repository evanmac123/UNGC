module ResourcesHelper
  def languages_for_select
    options_for_select Language.all.map { |c| [c.name, c.id] }
  end
end
