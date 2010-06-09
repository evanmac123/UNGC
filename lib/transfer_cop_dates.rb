class TransferCopDates
  cops = CommunicationOnProgress.find(:all, :conditions => 'starts_on IS NULL and ends_on IS NULL')
  puts "Found #{cops.count}"  
  
  cops.each do |cop|
    unless cop.start_year.blank? and cop.start_month.blank?
      cop.starts_on = Date.new(y = cop.start_year, m = cop.start_month, d = 1).to_s
      cop.ends_on = Date.new(y = cop.end_year, m = cop.end_month, d = 1).to_s
      if cop.save
        puts "The start date is: #{cop.starts_on} \t The end date is: #{cop.ends_on}"
      end
    end
  end
  
  # use added_on date
  cops = CommunicationOnProgress.find(:all,
                                      :conditions => 'starts_on IS NULL
                                                      AND ends_on IS NULL
                                                      AND start_year IS NULL
                                                      AND end_year IS NULL
                                                      AND added_on IS NOT NULL')
  
  cops.each do |cop|
    cop.starts_on = (cop.added_on - 1.year).to_s
    cop.ends_on = cop.added_on
    if cop.save
      puts "The start date is: #{cop.starts_on} \t The end date is: #{cop.ends_on}"
    end
  end
  
  
  # no added_on date, so use created_at and assume previous calendar year
  cops = CommunicationOnProgress.find(:all,
                                      :conditions => 'starts_on IS NULL
                                                      AND ends_on IS NULL
                                                      AND start_year IS NULL
                                                      AND end_year IS NULL
                                                      AND added_on IS NULL')
  
    cops.each do |cop|
      cop.starts_on = (cop.created_at - 1.year).to_s
      cop.ends_on = cop.created_at
      if cop.save
        puts "The start date is: #{cop.starts_on} \t The end date is: #{cop.ends_on}"
      end
    end

end