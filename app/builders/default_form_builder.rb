class DefaultFormBuilder < ActionView::Helpers::FormBuilder
  helpers = [:form_for, :apply_form_for_options!, :text_field, :password_field, :file_field,
                :text_area, :date_select, :datetime_select, :time_select, :check_box, :radio_button,
                :collection_select, :select, :country_select, :time_zone_select]

  helpers.each do |name|
    define_method(name) do |field, *args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      label = label(field, options[:label], :for => options[:label_for], :class => options[:label_class])

      #wrap with a li and place labels after checkboxes and radio buttons

      if name == :check_box || name == :radio_button
        @template.content_tag(:li, [super(field, *args), label].join(''), :class => options[:li_class])
      else
        @template.content_tag(:li, [label, super(field, *args)].join(''), :class => options[:li_class])
      end

    end
  end
end
