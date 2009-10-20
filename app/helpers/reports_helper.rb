module ReportsHelper
  def link_to_report(text, action)
    [link_to(text, report_path(:action => action)),
      link_to('csv', report_path(:action => action, :format => 'csv'))].join(' | ')
  end
  
  def select_month_tag(selected)
    select_tag :month, options_for_select((1..12).collect{|m| [Date::MONTHNAMES[m], m.to_s]}, selected.to_s)
  end
  
  def select_year_tag(selected)
    select_tag :year, options_for_select((Date.today.year-5..Date.today.year).collect {|y| y.to_s}, selected.to_s)
  end
end
