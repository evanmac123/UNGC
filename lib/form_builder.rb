class FormBuilder < ActionView::Helpers::FormBuilder
  helpers = field_helpers +
            [:date_select, :datetime_select, :time_select] +
            [:collection_select, :select, :country_select, :time_zone_select] -
            [:hidden_field, :label, :fields_for] # Don't decorate these

  helpers.each do |name|
    define_method(name) do |field, *args|
      options = args.last.is_a?(Hash) ? args.pop : {}
      label = label(field, options[:label], :class => options[:label_class])
      @template.content_tag(:p, label +'<br/>' + super(field, options))  #wrap with a paragraph 
    end
  end
end