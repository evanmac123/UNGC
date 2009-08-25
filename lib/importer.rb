require 'fastercsv'

# Importing data expects tables/models to exist and to have NO data
# If you import to a table with data, the auto increment ID field will
# not follow the sequence it may be expecting from the imported file
class Importer
  
  FILES = {
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :country   =>  'TR01_COUNTRY.TXT',
    # fields: ID	TYPE	TYPE_PROPERTY
    :organization_type => 'TR02_ORGANIZATION_TYPE.TXT',
    # fields: PRINCIPLE_ID	PRINCIPLE_NAME
    :principle => 'TR05_PRINCIPLE.TXT',
    # fields: INTEREST_ID	INTEREST_NAME
    :interest  => 'TR06_INTEREST.TXT',
    # fields: ROLE_ID ROLE_NAME
    :role      => 'TR07_ROLE.TXT',
    # fields: ROLE_ID ROLE_NAME
    # 0, Unknown - invalid id for mysql
    :language  => 'TR10_LANGUAGE.TXT'
  }
  
  # Imports all the data in files located in options[:folder]
  def run(options={:folder => File.join(RAILS_ROOT, 'lib/un7 tables')})
    @data_folder = options[:folder]
    FILES.each{|key, value| import key, value}
  end

  # Imports the data for a single file
  def import(name, file_name)
    file = File.join(@data_folder, file_name)
    FasterCSV.foreach(file, :col_sep => "\t",
                            :headers => :first_row) do |row|
      record = row
      puts "#{name}: #{record}"
      # TODO create an object of the correct type and save
    end
  end
end