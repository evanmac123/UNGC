require 'fastercsv'

class Importer
  
  FILES = [:country, :organization_type, :sector, :exchange, :language, :cop_score, :principle,
            :interest, :role, :organization, :contact, :logo_publication, :logo_request,
            :logo_file]
  CONFIG = {
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :country => {:file => 'TR01_COUNTRY.TXT', :fields => [:code, :name, :region, :network_type, :manager]},
    # fields: ID	TYPE	TYPE_PROPERTY
    :organization_type => {:file => 'TR02_ORGANIZATION_TYPE.TXT', :fields => [nil, :name, :type_property]},
    #fields: SECTOR_NAME	SECTOR_ID	ICB_NUMBER	SUPER_SECTOR
    :sector => {:file => 'TR03_SECTOR.TXT', :fields => [:name, :old_id, :icb_number, :parent_id]},
    #fields: COP_SCORE	COP_SCORE_DESCRIPTION
    :cop_score => {:file => 'TR04_COP_SCORE.TXT', :fields => [:old_id, :description]},
    # fields: PRINCIPLE_ID	PRINCIPLE_NAME
    :principle => {:file => 'TR05_PRINCIPLE.TXT', :fields => [:old_id, :name]},
    # fields: INTEREST_ID	INTEREST_NAME
    :interest  => {:file => 'TR06_INTEREST.TXT', :fields => [:old_id, :name]},
    # fields: ROLE_ID ROLE_NAME
    :role      => {:file => 'TR07_ROLE.TXT', :fields => [:old_id, :name]},
    #fields LIST_EXCHANGE_CODE	LIST_EXCHANGE_NAME	LIST_SECONDARY_CODE	LIST_TERTIARY_CODE	TR01_COUNTRY_ID
    :exchange => {:file => 'TR08_EXCHANGE.TXT', :fields => [:code, :name, :secondary_code, :terciary_code, :country_id]},
    # fields: LANGUAGE_ID	LANGUAGE_NAME
    :language => {:file => 'TR10_LANGUAGE.TXT', :fields => [:old_id, :name]},
    # fields: ID	NAME	PARENT_ID	DISPLAY_ORDER

    :logo_publication => {:file => 'TR14_LOGO_PUBLICATIONS.txt', :fields => [:old_id, :name, :parent_id, :display_order]},
    # fields: ID	DATE_REQUESTED	DATE_STATUS	PUBLICATION_ID	ORG_ID	CONTACT_ID	REVIEWER_ID	REPLIED_TO
    #             PURPOSE	REQUEST_STATUS	POLICY_ACCEPTED	POLICY_ACCEPTED_DATE
    :logo_request => {:file   => 'TR15_LOGO_REQUESTS.TXT',
                      :fields => [:old_id, :requested_on, :status_changed_on, :publication_id, :organization_id,
                                    :contact_id, :reviewer_id, :replied_to, :purpose, :status, :accepted, :accepted_on]},
    # fields: ID	LOGO_NAME	DESCRIPTION	THUMBNAIL	LOGOFILE
    :logo_file => {:file => 'TR18_LOGO_FILES.TXT', :fields => [:old_id, :name, :description, :thumbnail, :file]},
    # fields: ID	COMMENT_DATE	LOGO_REQUEST_ID	CONTACT_ID	TEXT
    :logo_comment => {:file => 'TR17_LOGO_COMMENTS.TXT', :fields => [:old_id, :added_on, :logo_request_id, :contact_id, :body]},

    # trying a real table, just a few fields
    #fields: ID	TR02_TYPE	ORG_NAME	SECTOR_ID ORG_NETWORK_BIT	ORG_PARTICIPANT_BIT	ORG_NB_EMPLOY	ORG_URL
    :organization => {:file   => 'R01_ORGANIZATION.TXT',
                      :fields => [:old_id, :organization_type_id, :name, :sector_id, :local_network, :participant,
                                   :employees, :url]},
    # fields CONTACT_ID	CONTACT_FNAME	CONTACT_MNAME	CONTACT_LNAME	CONTACT_PREFIX	CONTACT_JOB_TITLE	CONTACT_EMAIL	
    #        CONTACT_PHONE	CONTACT_MOBILE	CONTACT_FAX	R01_ORG_NAME	CONTACT_ADRESS	CONTACT_CITY	CONTACT_STATE	
    #        CONTACT_CODE_POSTAL	TR01_COUNTRY_ID	CONTACT_IS_CEO	CONTACT_IS_CONTACT_POINT	CONTACT_IS_NEWSLETTER	
    #        CONTACT_IS_ADVISORY_COUNCIL	CONTACT_LOGIN	CONTACT_PWD	CONTACT_ADDRESS2
    :contact => {:file   => 'R10_CONTACTS.TXT',
                 :fields => [:old_id, :first_name, :middle_name, :last_name, :prefix, :job_title, :email,
                              :phone, :mobile, :fax, :organization_id, :address, :city, :state,
                              :postal_code, :country_id, :ceo, :contact_point, :newsletter, 
                              :advisory_council, :login, :password, :address_more]}
  }
  
  # Imports all the data in files located in options[:folder]
  def run(options={})
    setup(options)
    @files.each{|entry| import(entry, CONFIG[entry])}
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
          if name == :sector
            # sector tree depends on the icb_number field
            o.parent_id = Sector.find_by_icb_number(row[i]).id if row[i]
          else
            o.parent_id = model.find_by_old_id(row[i]).id if row[i]
          end
        elsif field == :sector_id
          o.sector_id = Sector.find_by_old_id(row[i]).id if row[i]
        elsif field == :publication_id
          o.publication_id = LogoPublication.find_by_old_id(row[i]).id if row[i]
        elsif field == :logo_request_id
          o.logo_request_id = LogoRequest.find_by_old_id(row[i]).id if row[i]
        elsif field == :organization_id
          if name == :contact
            # contact table is linked to organization by name
            o.organization_id = Organization.find_by_name(row[i]).try(:id) if row[i]
          else
            o.organization_id = Organization.find_by_old_id(row[i]).id if row[i]
          end
        elsif field == :contact_id || field == :reviewer_id
          o.send("#{field}=", Contact.find_by_old_id(row[i]).try(:id)) if row[i]
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
  
  def delete_all(options={})
    setup(options)
    @files.each{|entry| entry.to_s.classify.constantize.delete_all}
  end

  def delete_all_and_run(options={})
    delete_all(options)
    run(options)
  end

  private
    def setup(options)
      @data_folder = options[:folder] || File.join(RAILS_ROOT, 'lib/un7 tables')
      if options[:files]
        @files = options[:files].is_a?(Array) ? options[:files] : [options[:files]]
      else
        @files = FILES
      end
    end
end