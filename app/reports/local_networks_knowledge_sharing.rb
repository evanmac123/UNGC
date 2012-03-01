class LocalNetworksKnowledgeSharing < SimpleReport

  def records
    LocalNetwork.find_by_sql("
    SELECT l.name,
           'Award'       AS 'item',
           a.title       AS 'title',
           a.award_type  AS 'type',
           a.date
    FROM   awards a
           JOIN local_networks l
             ON l.id = a.local_network_id
    UNION
    SELECT l.name,
           'Meeting'      AS 'item',
           ''             AS 'title',
           m.meeting_type AS 'type',
           m.date
    FROM   meetings m
           JOIN local_networks l
             ON l.id = m.local_network_id
    UNION
    SELECT l.name,
           'Communication'      AS 'item',
           c.title              AS 'title',
           c.communication_type AS 'type',
           c.date
    FROM   communications c
           JOIN local_networks l
             ON l.id = c.local_network_id
    ")
  end

  def headers
    [ 'Local Network',
      'Item',
      'Title',
      'Type',
      'Date'

    ]
  end

  def row(record)
  [ record.name,
    record.item,
    record.title,
    record.type,
    record.date
  ]
  end

end
