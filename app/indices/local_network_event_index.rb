ThinkingSphinx::Index.define :local_network_event, :with => :active_record do
  indexes title
  indexes description
  indexes file_content

  has date
  has local_network_id
  has country_id
  has 'CRC32(event_type)', :as => :event_type_crc, :type => :integer
  has 'CRC32(region)',     :as => :region_crc,     :type => :integer
  has principles(:id),     :as => :principle_ids
end
