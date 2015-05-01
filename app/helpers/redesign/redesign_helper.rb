module Redesign::RedesignHelper
  def link_to_redesign(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)

    if url !~/\A\/redesign/ && url !~/\Ahttp(s?)|\Amailto/
      url = '/redesign' + url
    end

    html_options['href'] ||= url
    content_tag(:a, name || url, html_options, &block)
  end

  def search_filter(filter)
    raw render('redesign/components/filter_options_list',
        label: filter.label,
        filter: filter.parents,
        child_filter: filter.children,
        options: filter.options)
  end

end
