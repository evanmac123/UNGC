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

  def filter_list(disabled)
    if block_given?
      yield FilterList.new(self, disabled)
    end
  end

  private

  FilterList = Struct.new(:helper, :disabled?) do

    def render_filter(filter)
      options = {
        label: filter.label,
        filter: filter.key,
        options: filter.options,
        disabled: disabled?,
      }

      if filter.child_key
        options[:child_filter] = filter.child_key
      end

      helper.raw helper.render('redesign/components/filter_options_list', options)
    end

  end

end
