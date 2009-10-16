class ListedCompaniesFormatter < SimpleFormatter
  def headers
    ['Participant ID','Company Name','Country','Ticker Symbol',
      'Exchange Code','Reuters Code','ISO 10383 Code']
  end

  def row(record)
    [record.id, record.name, record.country.name, record.stock_symbol, record.exchange.code,
      record.exchange.secondary_code, record.exchange.terciary_code]
  end
end