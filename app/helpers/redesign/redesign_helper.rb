module Redesign::RedesignHelper

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
