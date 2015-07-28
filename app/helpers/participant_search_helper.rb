module ParticipantSearchHelper

  def participants_table(search, results)
    options = {
      participants: results,
      sort_field: search.sort_field,
      sort_direction: search.sort_direction
    }
    raw(render 'redesign/components/participants_table', options)
  end

  def sort_headers(sort_field, sort_direction)
    yield SortHeader.new(self, sort_field, sort_direction)
  end

  private

  SortHeader = Struct.new(:helper, :active_field, :active_direction) do

    def header(label, field)
      css_class = "sort-direction-toggle #{field.dasherize}"

      if field == active_field
        css_class += " active-sort #{active_direction}"
      end

      options = {'data-field' => field, 'class' => css_class}
      helper.raw(helper.content_tag(:th, label, options))
    end

  end

end
