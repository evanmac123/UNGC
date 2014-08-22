class ListedCompaniesReport < SimpleReport

  def records
    Organization.listed
  end

  def render_output
    self.render_xls_in_batches
  end

  def headers
    [ 'Participant ID',
      'Company Name',
      'Country',
      'ISIN',
      'Ticker Symbol',
      'Exchange Code',
      'Reuters Code',
      'ISO 10383 Code',
      'Active?',
      'Sector'
    ]
  end

  def row(record)
    [ record.id,
      record.name,
      record.country.try(:name),
      record.isin,
      record.stock_symbol,
      record.exchange.try(:code),
      record.exchange.try(:secondary_code),
      record.exchange.try(:terciary_code),
      record.active,
      record.sector_name
    ]
  end
end
