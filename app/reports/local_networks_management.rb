class LocalNetworksManagement < SimpleReport

  def records
    LocalNetwork.all(:include => [ :countries ])
  end

  def headers
    [ 'Local Network',
      'Region',
      'Website',
      'Development Stage',
      'Created on',
      'Modified on',
      'Launch Date of Global Compact',
      'Launch Date of Local Network',
      'Appointments made during Annual Meeting?',
      'Appointments made during Annual Meeting (file)',
      'Network Representative Appointed?',
      'Steering Commitee Appointed?',
      'Contact Person Appointed?',
      'Established as a Legal Entity?',
      'Established as a Legal Entity (file)',
      'Subsidiary Participation?',
      'Number of Companies',
      'Number of SMEs',
      'Number of Micro Enterprises',
      'Number of Business Associations',
      'Number of CSR Organizations',
      'Number of Labour Organizations',
      'Number of Civil Society Organizations',
      'Number of Academic Institutions',
      'Number of Government Representatives',
      'Participant Fees?',
      '($) Company Fee',
      '($) SME Fee',
      '($) Other Fee',
      'Budget - % of Participant Fees',
      'Budget - % of Private Voluntary',
      'Budget - % of Public Voluntary'
    ]
  end

  def row(record)
  [ record.name,
    record.region_name,
    record.url,
    record.humanize_state,
    record.created_at.strftime('%Y-%m-%d'),
    record.updated_at.strftime('%Y-%m-%d'),
    record.sg_global_compact_launch_date,
    record.sg_local_network_launch_date,
    record.sg_annual_meeting_appointments? ? 1:0,
    record.sg_annual_meeting_appointments_file.try(:attachment_unmodified_filename),
    record.sg_selected_appointees_local_network_representative? ? 1:0,
    record.sg_selected_appointees_steering_committee? ? 1:0,
    record.sg_selected_appointees_contact_point? ? 1:0,
    record.sg_established_as_a_legal_entity? ? 1:0,
    record.sg_established_as_a_legal_entity_file.try(:attachment_unmodified_filename),
    record.membership_subsidiaries? ? 1:0,
    record.membership_companies,
    record.membership_sme,
    record.membership_micro_enterprise,
    record.membership_business_organizations,
    record.membership_csr_organizations,
    record.membership_labour_organizations,
    record.membership_civil_societies,
    record.membership_academic_institutions,
    record.membership_government,
    record.fees_participant? ? 1:0,
    record.fees_amount_company,
    record.fees_amount_sme,
    record.fees_amount_other_organization,
    record.fees_amount_participant,
    record.fees_amount_voluntary_private,
    record.fees_amount_voluntary_public
  ]
  end

end
