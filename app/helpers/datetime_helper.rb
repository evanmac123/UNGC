module DatetimeHelper
  # TODO convert these to calls to I18n.l

  def yyyy_mm_dd(date)
    date ? date.strftime('%Y/%m/%d') : '&nbsp;'
  end

  def dd_month_yyyy(date)
    date ? date.strftime('%e %B, %Y') : '&nbsp;'
  end

end
