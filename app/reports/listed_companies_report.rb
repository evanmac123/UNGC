class ListedCompaniesReport < SimpleReport
  def records
    Organization.listed.all(:include => [:country, :exchange])
  end
  
  def headers
    ['Participant ID','Company Name','Country','Ticker Symbol',
      'Exchange Code','Reuters Code','ISO 10383 Code']
  end

  def row(record)
    [record.id, record.name, record.country.name, record.stock_symbol, record.exchange.try(:code),
      record.exchange.try(:secondary_code), record.exchange.try(:terciary_code)]
  end
end