module Admin::CopsHelper
  def true_or_false_field(form, field)
    html = tag("br")
    html << form.radio_button(field, 'true')
    html << form.label(field, 'True', :value => 'true')
    html << tag("br")
    html << form.radio_button(field, 'false')
    html << form.label(field, 'False', :value => 'false')
    return html
  end
end
