require 'fastercsv'

class Importer
  
  FILES = [:country, :organization_type, :sector, :exchange, :listing_status, :language, :removal_reason,
            :cop_score, :principle, :interest, :role, :organization, :contact, :communication_on_progress,
            :logo_publication, :logo_request, :logo_file, :logo_comment, :case_story]
  CONFIG = {
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :country => {:file => 'TR01_COUNTRY.txt', :fields => [:code, :name, :region, :network_type, :manager]},
    # fields: ID	TYPE	TYPE_PROPERTY
    :organization_type => {:file => 'TR02_ORGANIZATION_TYPE.txt', :fields => [nil, :name, :type_property]},
    #fields: SECTOR_NAME	SECTOR_ID	ICB_NUMBER	SUPER_SECTOR
    :sector => {:file => 'TR03_SECTOR.txt', :fields => [:name, :old_id, :icb_number, :parent_id]},
    #fields: COP_SCORE	COP_SCORE_DESCRIPTION
    :cop_score => {:file => 'TR04_COP_SCORE.txt', :fields => [:old_id, :description]},
    # fields: PRINCIPLE_ID	PRINCIPLE_NAME
    :principle => {:file => 'TR05_PRINCIPLE.txt', :fields => [:old_id, :name]},
    # fields: INTEREST_ID	INTEREST_NAME
    :interest  => {:file => 'TR06_INTEREST.txt', :fields => [:old_id, :name]},
    # fields: ROLE_ID ROLE_NAME
    :role      => {:file => 'TR07_ROLE.txt', :fields => [:old_id, :name]},
    #fields LIST_EXCHANGE_CODE	LIST_EXCHANGE_NAME	LIST_SECONDARY_CODE	LIST_TERTIARY_CODE	TR01_COUNTRY_ID
    :exchange => {:file => 'TR08_EXCHANGE.txt', :fields => [:code, :name, :secondary_code, :terciary_code, :country_id]},
    # fields: Listing_ID	Listing_Name
    :listing_status => {:file => 'TR09_LISTING_STATUS.txt', :fields => [:old_id, :name]},
    # fields: LANGUAGE_ID	LANGUAGE_NAME
    :language => {:file => 'TR10_LANGUAGE.txt', :fields => [:old_id, :name]},
    # fields: REASON_ID	REASON_DESCRIPTION
    :removal_reason => {:file => 'TR11_REASON_FOR_REMOVAL.txt', :fields => [:old_id, :description]},
    # fields: ID	NAME	PARENT_ID	DISPLAY_ORDER
    :logo_publication => {:file => 'TR14_LOGO_PUBLICATIONS.txt', :fields => [:old_id, :name, :parent_id, :display_order]},
    # fields: ID	DATE_REQUESTED	DATE_STATUS	PUBLICATION_ID	ORG_ID	CONTACT_ID	REVIEWER_ID	REPLIED_TO
    #             PURPOSE	REQUEST_STATUS	POLICY_ACCEPTED	POLICY_ACCEPTED_DATE
    :logo_request => {:file   => 'TR15_LOGO_REQUESTS.txt',
                      :fields => [:old_id, :requested_on, :status_changed_on, :publication_id, :organization_id,
                                    :contact_id, :reviewer_id, :replied_to, :purpose, :status, :accepted, :accepted_on]},
    # fields: ID	LOGO_NAME	DESCRIPTION	THUMBNAIL	LOGOFILE
    :logo_file => {:file => 'TR18_LOGO_FILES.txt', :fields => [:old_id, :name, :description, :thumbnail, :file]},
    # fields: ID	COMMENT_DATE	LOGO_REQUEST_ID	CONTACT_ID	TEXT
    :logo_comment => {:file => 'TR17_LOGO_COMMENTS.txt', :fields => [:old_id, :added_on, :logo_request_id, :contact_id, :body]},

    #fields: ID	TR02_TYPE	ORG_NAME	SECTOR_ID ORG_NETWORK_BIT	ORG_PARTICIPANT_BIT	ORG_NB_EMPLOY	ORG_URL
    #        ORG_BHR_URL	ORG_DATE_CREATE	ORG_DATE_MODIFICATION	ORG_DATE_JOINING	ORG_DATE_DELISTED	ORG_ACTIVE
    #        ORG_ISGLOBAL500	TR01_COUNTRY_ID	ORG_STATUS_COP	ORG_COP_ALERT	ORG_UN_SPEC	ORG_PART_MAIL
    #        ORG_30DAYS_TO_COP	ORG_90DAYS_TO_COP	ORG_TODAY_COPDUE	ORG_TODAY_INACT	ORG_30DAYS_TO_INACT
    #        ORG_90DAYS_TO_INACT	ORG_MEMBER_ONEYEAR	ORG_LISTED_STATUS	ORG_LIST_CODE	ORG_LIST_EXCHANGE_CODE
    #        ORG_PARENT_NAME	ORG_PARENT_LIST_CODE	TR11_REASON	ORG_LAST_MODIFIED_BY	ORG_JOIN_LETTER
    :organization => {:file   => 'R01_ORGANIZATION.txt',
                      :fields => [:old_id, :organization_type_id, :name, :sector_id, :local_network, :participant,
                                   :employees, :url, nil, :added_on, :modified_on, :joined_on, :delisted_on,:active,
                                   nil, :country_id, nil, nil, nil, nil,
                                   nil, nil, nil, nil, nil,
                                   nil, nil, nil, :stock_symbol, nil,
                                   nil, nil, :removal_reason_id, :last_modified_by_id, nil]},
    # fields: CONTACT_ID	CONTACT_FNAME	CONTACT_MNAME	CONTACT_LNAME	CONTACT_PREFIX	CONTACT_JOB_TITLE	CONTACT_EMAIL
    #         CONTACT_PHONE	CONTACT_MOBILE	CONTACT_FAX	R01_ORG_NAME	CONTACT_ADRESS	CONTACT_CITY	CONTACT_STATE
    #         CONTACT_CODE_POSTAL	TR01_COUNTRY_ID	CONTACT_IS_CEO	CONTACT_IS_CONTACT_POINT	CONTACT_IS_NEWSLETTER
    #         CONTACT_IS_ADVISORY_COUNCIL	CONTACT_LOGIN	CONTACT_PWD	CONTACT_ADDRESS2
    :contact => {:file   => 'R10_CONTACTS.txt',
                 :fields => [:old_id, :first_name, :middle_name, :last_name, :prefix, :job_title, :email,
                              :phone, :mobile, :fax, :organization_id, :address, :city, :state,
                              :postal_code, :country_id, :ceo, :contact_point, :newsletter, 
                              :advisory_council, :login, :password, :address_more]},
    # fields: COP_ID	R01_ORG_NAME	COP_TITLE	COP_DOCUMENT_RELATED	COP_CONTACT_EMAIL	COP_PERIOD_START_YEAR	
    #         COP_FACILITATOR	COP_CONTACT_TITLE	COP_PERIOD_START_MONTH	COP_PERIOD_END_MONTH	COP_PERIOD_LINK1
    #         COP_PERIOD_LINK2	COP_PERIOD_LINK3	COP_DATE_CREATE	COP_DATE_MODIFICATION	COP_CONTACT_PERSON
    #         COP_PERIOD_END_YEAR	COP_DOCUMENT_STATUS	COP_CEO_COMMIT_LETTER	COP_DESCRIPTION_ACTIONS	COP_USE_INDICATORS
    #         TR04_SCORE	COP_USE_GRI	COP_HAS_CERTIFICATION	COP_NOTABLE_PROGRAM
    :communication_on_progress => {:file   => 'R02_COM_ON_PROCESS.txt',
                                   :fields => [:identifier, :organization_id, :title, :related_document, :email, :start_year,
                                               :facilitator, :job_title, :start_month, :end_month, :url1,
                                               :url2, :url3, :added_on, :modified_on, :contact_name,
                                               :end_year, :status, :include_ceo_letter, :include_actions, :include_measurement, :use_indicators,
                                               :cop_score_id, :use_gri, :has_certification, :notable_program]},
    # fields: CASE_ID	R01_ORG_NAME	CASE_TITLE	CASE_STORY_TYPE	CASE_CATEGORY	CASE_DATE	CASE_DESCRIPTION
    #         CASE_URL_LINK1	CASE_URL_LINK2	CASE_URL_LINK3	CASE_AUTHOR	CASE_AUTHOR_INSTITUTION
    #         CASE_AUTHOR_EMAIL	CASE_AUTHOR2	CASE_AUTHOR2_INSTITUTION	CASE_AUTHOR2_EMAIL	CASE_REVIEWER
    #         CASE_REVIEWER_INSTITUTION	CASE_REVIEWER_EMAIL	CASE_REVIEWER2	CASE_REVIEWER2_INSTITUTION
    #         CASE_REVIEWER2_EMAIL	CASE_FILE	CASE_CONTACT1_NAME	CASE_CONTACT1_EMAIL	CASE_CONTACT2_NAME
    #         CASE_CONTACT2_EMAIL	CASE_STATUS	CASE_DOC_EXT
    :case_story => {:file   => 'R07_CASE_STORY.txt',
                    :fields => [:identifier, :organization_id, :title, :case_type, :category, :case_date, :description,
                                :url1, :url2, :url3, :author1, :author1_institution,
                                :author1_email, :author2, :author2_institution, :author2_email, :reviewer1,
                                :reviewer1_institution, :reviewer1_email, :reviewer2, :reviewer2_institution,
                                :reviewer2_email, :uploaded, :contact1, :contact1_email, :contact2,
                                :contact2_email, :status, :extension]}
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
    model = name.to_s.camelize.constantize
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
        elsif field == :cop_score_id
          o.cop_score_id = CopScore.find_by_old_id(row[i]).id if row[i]
        elsif field == :logo_request_id
          o.logo_request_id = LogoRequest.find_by_old_id(row[i]).id if row[i]
        elsif field == :logo_file_id
          o.logo_file_id = LogoFile.find_by_old_id(row[i]).id if row[i]
        elsif field == :removal_reason_id
          o.removal_reason_id = RemovalReason.find_by_old_id(row[i]).id if row[i]
        elsif field == :organization_id
          if [:contact, :communication_on_progress, :case_story].include? name
            # some tables are linked to organization by name
            o.organization_id = Organization.find_by_name(row[i]).try(:id) if row[i]
          else
            o.organization_id = Organization.find_by_old_id(row[i]).id if row[i]
          end
        elsif [:contact_id, :reviewer_id, :last_modified_by_id].include? field
          o.send("#{field}=", Contact.find_by_old_id(row[i]).try(:id)) if row[i]
        elsif field == :organization_type_id
          o.organization_type_id = OrganizationType.find_by_name(row[i]).id if row[i]
        else
          o.send("#{field}=", row[i])
        end
      end
      update_state(name, o)
      saved = o.save
      puts "** Could not save #{name}: #{row}"unless saved
    end
  end
  
  def delete_all(options={})
    setup(options)
    @files.each{|entry| entry.to_s.camelize.constantize.delete_all}
  end

  def delete_all_and_run(options={})
    delete_all(options)
    run(options)
  end

  private
    def setup(options)
      @data_folder = options[:folder] || File.join(RAILS_ROOT, 'lib/un7_tables')
      if options[:files]
        @files = options[:files].is_a?(Array) ? options[:files] : [options[:files]]
      else
        @files = FILES
      end
    end

    # translates the old database status into our state fields
    def update_state(name, model)
      if name == :logo_request
        # (0: “Pending Review” 1: “In Review”, 2”:“Declined” or 3:“Accepted)
        model.state = ['pending_review', 'pending', 'rejected', 'approved'][model.status.to_i]
      end
    end
end