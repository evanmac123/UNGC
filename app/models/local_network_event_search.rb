class LocalNetworkEventSearch < OpenStruct
  def results
    @results ||= perform_search
  end

  def perform_search
    filters = {}

    if start_date.present? or end_date.present?
      start_date_d = if start_date.present?
                       Date.parse(start_date)
                     else
                       Date.parse('1900-01-01')
                     end

      end_date_d = if end_date.present?
                     Date.parse(end_date)
                   else
                     Date.today
                   end

      filters[:date] = (start_date_d.to_time .. end_date_d.to_time)
    end

    if event_type.present?
      filters[:event_type_crc] = event_type.to_crc32
    end

    if principle_id.present?
      filters[:principle_ids] = principle_id.to_i
    end

    if region.present?
      filters[:region_crc] = region.to_crc32
    end

    if local_network_id.present?
      filters[:local_network_id] = local_network_id.to_i
    end

    LocalNetworkEvent.search(fulltext, :with => filters, :order => :date)
  end
end

