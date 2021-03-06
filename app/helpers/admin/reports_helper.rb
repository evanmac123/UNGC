module Admin::ReportsHelper

  def link_to_report_html(text, action)
    [link_to(text, admin_report_path(:action => action, :format => 'html')),
     link_to(text, admin_report_path(:action => action, :format => 'html'), :class => 'doc')].join(' ').html_safe
  end

  def link_to_report_xls(text, action)
    [link_to(text, admin_report_path(:action => action, :format => 'xls'), remote: true),
     link_to(text, admin_report_path(:action => action, :format => 'xls'), remote: true, :class => 'xls')].join(' ').html_safe
  end

  def link_to_download_report(options = {})
    format = options.fetch(:format) { 'xls' }
    text   = options.fetch(:text)   { 'Download Excel file' }
    url    = options.fetch(:url)    { url_for(params.merge(format: format)) }

    link_to text, url, remote: true, :class => 'download_large'
  end

  def select_month_tag(selected)
    select_tag :month, options_for_select((1..12).collect{|m| [Date::MONTHNAMES[m], m.to_s]}, selected.to_s)
  end

  def select_year_tag(selected)
    select_tag :year, options_for_select((Date.current.year-5..Date.current.year).collect {|y| y.to_s}, selected.to_s)
  end

  def boolean_reponse(response)
    case response
      when nil
        ""
       when true
         "Yes"
       when false
         "No"
    end
  end

end
