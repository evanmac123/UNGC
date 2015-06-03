module Redesign::RedesignHelper

  def link_to_redesign(name = nil, options = nil, html_options = nil, &block)
    html_options, options, name = options, name, block if block_given?
    options ||= {}

    html_options = convert_options_to_data_attributes(options, html_options)

    url = url_for(options)


    unless has_redesign?
      if url !~/\A\/redesign/ && url !~/\Ahttp(s?)|\Amailto/
        url = '/redesign' + url
      end
    end

    html_options['href'] ||= url
    content_tag(:a, name || url, html_options, &block)
  end

  def search_filter(filter, disabled: false)
    options = {
      label: filter.label,
      filter: filter.key,
      options: filter.options,
      disabled: disabled,
    }

    if filter.child_key
      options[:child_filter] = filter.child_key
    end

    raw render('redesign/components/filter_options_list', options)
  end

  def active_filters(search)
    options = {
      active_filters: search.active_filters,
      disabled: search.disabled?
    }
    raw render('redesign/components/active_filters_list', options)
  end

end
