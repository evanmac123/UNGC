class CopWaterMandateSubmissions < SimpleReport

  def records
    Organization.for_initiative(:water_mandate).participants.all( :include => [:communication_on_progresses] )
  end

  def headers
    [ 'Participant ID',
      'Participant Name',
      'COP Title',
      'Covers COP-Water?',
      'Published On',
      'COP Status',
      'Next COP Due'
      ]
  end

  def row(record)
    if record.last_approved_cop
      [ record.id,
        record.name,
        record.last_approved_cop.title,
        boolean_reponse(record.last_approved_cop.references_water_mandate),
        record.last_approved_cop.published_on.strftime('%Y-%m-%d'),
        record.cop_state.humanize,
        record.cop_due_on.strftime('%Y-%m-%d') ]
    else
      [ record.id,
        record.name,
        '',
        '',
        '',
        record.cop_state.humanize,
        record.cop_due_on.strftime('%Y-%m-%d') ]
    end
  end

end
