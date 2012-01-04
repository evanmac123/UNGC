module DatetimeHelper

  def m_yyyy(date)
    date ? date.strftime('%%s/%Y') % date.month.to_s : '&nbsp;'
  end

  def yyyy_mm_dd(date)
    date ? date.strftime('%Y/%m/%d') : '&nbsp;'
  end

  def mm_dd_yyyy(date)
    date ? date.strftime('%m/%d/%Y') : '&nbsp;'
  end

  def dd_month_yyyy(date)
    date ? date.strftime('%e %B, %Y') : '&nbsp;'
  end

  def current_year
    Time.now.strftime('%Y').to_i
  end

end
