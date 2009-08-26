require 'fastercsv'

# Importing data expects tables/models to exist and to have NO data
# If you import to a table with data, the auto increment ID field will
# not follow the sequence it may be expecting from the imported file
class Importer
  
  FILES = [
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    [:country, {:file => 'TR01_COUNTRY.TXT', :fields => [:code, :name, :region, :network_type, :manager]}],
    # fields: ID	TYPE	TYPE_PROPERTY
    [:organization_type, {:file => 'TR02_ORGANIZATION_TYPE.TXT', :fields => [nil, :name, :type_property]}],
    #fields: SECTOR_NAME	SECTOR_ID	ICB_NUMBER	SUPER_SECTOR
    [:sector, {:file => 'TR03_SECTOR.TXT', :fields => [:name, :old_id, :icb_number, :parent_id]}],

    # fields: PRINCIPLE_ID	PRINCIPLE_NAME
    #:principle => 'TR05_PRINCIPLE.TXT',
    # fields: INTEREST_ID	INTEREST_NAME
    #:interest  => 'TR06_INTEREST.TXT',
    # fields: ROLE_ID ROLE_NAME
    #:role      => 'TR07_ROLE.TXT',
    #fields LIST_EXCHANGE_CODE	LIST_EXCHANGE_NAME	LIST_SECONDARY_CODE	LIST_TERTIARY_CODE	TR01_COUNTRY_ID
    [:exchange, {:file => 'TR08_EXCHANGE.TXT', :fields => [:code, :name, :secondary_code, :terciary_code, :country_id]}],

    # fields: ROLE_ID ROLE_NAME
    # 0, Unknown - invalid id for mysql
    #:language  => 'TR10_LANGUAGE.TXT'

    # trying a real table, trying just a few fields
    #fields: ID	TR02_TYPE	ORG_NAME	SECTOR_ID ORG_NETWORK_BIT	ORG_PARTICIPANT_BIT	ORG_NB_EMPLOY	ORG_URL
    [:organization, {:file   => 'R01_ORGANIZATION.TXT',
                     :fields => [:old_id, :organization_type_id, :name, :sector_id, :local_network, :participant,
                                  :employees, :url]}]
  ]
  
  # Imports all the data in files located in options[:folder]
  def run(options={:folder => File.join(RAILS_ROOT, 'lib/un7 tables')})
    @data_folder = options[:folder]
    FILES.each{|entry| import entry.first, entry.last}
  end

  # Imports the data from a single file
  def import(name, options)
    puts "Importing #{name}.."
    file = File.join(@data_folder, options[:file])
    model = name.to_s.classify.constantize
    # read the file
    FasterCSV.foreach(file, :col_sep => "\t",
                            :headers => :first_row) do |row|
      # create an object of the correct type and save
      o = model.new
      options[:fields].each_with_index do |field,i|
        next if field.nil?
        # fields that end with _id require a lookup
        if field == :country_id
          o.country_id = Country.find_by_code(row[i]).id
        elsif field == :parent_id
          # this only works for sector - for now
          o.parent_id = Sector.find_by_icb_number(row[i]).id if row[i]
        elsif field == :sector_id
          o.sector_id = Sector.find_by_old_id(row[i]).id if row[i]
        elsif field == :organization_type_id
          o.organization_type_id = OrganizationType.find_by_name(row[i]).id if row[i]
        else
          o.send("#{field}=", row[i])
        end
      end
      saved = o.save
      puts "** Could not save #{name}: #{row}"unless saved
    end
  end
  
  def delete_all
    Importer::FILES.collect{|entry| entry.first.to_s.classify.constantize}.each &:delete_all
  end
  
  def delete_all_and_run
    delete_all
    run
  end
end