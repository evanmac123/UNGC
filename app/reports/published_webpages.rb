class PublishedWebpages < SimpleReport
  def records
    Page.approved.includes(:section).order("page_groups.position, pages.group_id, pages.parent_id, pages.path, pages.position")
  end

  def headers
    [ 'Page ID',
      'Path',
      'Title',
      'Main Section',
      'Main Section Order',
      'Parent Section',
      'Visible in Navigation?',
      'Order in Navigation',
      'Number of Versions',
      'Last Updates on'
    ]
  end

  def row(record)
    [ 
      record.id,
      record.path,
      record.title,
      record.section.try(:title),
      record.section.try(:position),
      record.parent.try(:title),
      record.display_in_navigation ? 'Yes' : 'No',
      record.position,
      record.version_number,
      record.approved_at
    ]
  end

end