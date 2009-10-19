module ReportsHelper
  def link_to_report(text, action)
    [link_to(text, report_path(:action => action)),
      link_to('csv', report_path(:action => action, :format => 'csv'))].join(' | ')
  end
end
