class FormBuilder < ActionView::Helpers::FormBuilder
  helpers = [:form_for, :apply_form_for_options!, :text_field, :password_field, :file_field,
                :text_area, :check_box, :date_select, :datetime_select, :time_select,
                :collection_select, :select, :country_select, :time_zone_select]

  helpers.each do |name|
    define_method(name) do |field, *args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      label = label(field, options[:label], :class => options[:label_class])
      @template.content_tag(:p, label +'<br/>' + super(field, *args))  #wrap with a paragraph
    end
  end
end