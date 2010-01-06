module NewsHelper
  def headlines
    Headline.recent
  end
  
  def formatted_dateline(headline, string='(')
    # =(#{@headline.location}, #{@headline.formatted_date}) &ndash;
    string << "#{headline.location}, " unless headline.location.blank?
    string << "#{headline.formatted_date}) &ndash; "
  end
end
