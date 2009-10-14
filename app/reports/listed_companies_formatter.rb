require 'csv'

class ListedCompaniesFormatter
  def render_html(records)
    "html report"
  end

  def render_csv(records)
    buffer = CSV.generate_line(['Participant ID','Company Name','Country','Ticker Symbol',
                                  'Exchange Code','Reuters Code','ISO 10383 Code'])
    
    CSV.generate(buffer) do |csv|
      records.each do |r|
        csv << [r.id, r.name, r.country.name, r.stock_symbol, r.exchange.code, 
                  r.exchange.secondary_code, r.exchange.terciary_code]
      end
    end
    
    return buffer
  end
end