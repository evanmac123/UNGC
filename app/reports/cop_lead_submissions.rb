class CopLeadSubmissions < SimpleReport

  def records
    Organization.for_initiative(:lead).all( :include => [:communication_on_progresses],
                                            :conditions => { :participant => true },
                                            :order => "communication_on_progresses.created_at DESC"                                          )
  end

  def headers
    [ 'Participant ID',
      'Participant Name',
      'COP Title',
      'COP Differentiation',
      'Missing required items?',
      'Missing LEAD criteria?',
      'Submitted On',
      'Next COP'
      ]
  end

  def row(record)
    [ record.id,
      record.name,
      record.last_approved_cop.title,
      record.last_approved_cop.differentiation_level_name,
      !record.last_approved_cop.is_grace_letter? && record.last_approved_cop.missing_items? ? 'Yes': '',
      record.last_approved_cop.lead_cop_is_incomplete? ? 'Yes': '',
      record.last_approved_cop.created_at.strftime('%Y-%m-%d'),
      record.cop_due_on.strftime('%Y-%m-%d') ]
  end

end
