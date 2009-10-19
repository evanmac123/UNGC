class BulletinSubscribersReport < SimpleReport
  def records
    BulletinSubscriber.all
  end
  
  def headers
    ['Email']
  end

  def row(record)
    [record.email]
  end
end