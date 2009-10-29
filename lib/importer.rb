require 'csv'

class Importer
  
  FILES = [:country, :organization_type, :sector, :exchange, :listing_status, :language, :removal_reason,
            :cop_score, :principle, :interest, :role, :organization, :contact, :communication_on_progress,
            :logo_publication, :logo_request, :logo_file, :logo_comment, :case_story, :initiative, :signing,
            :bulletin_subscriber]
  CONFIG = {
    #fields: ID	NAME
    :initiative => {
      :file => 'TR13_INITIATIVES.csv',
      :fields => [ :old_id, :name ]
    },
    #fields: ID	INITIATIVE_ID	ORG_ID	DATE_ADDED
    :signing => {
      :file => 'R16_XREF_R01_TR13.csv',
      :fields => [:old_id, :initiative_id, :organization_id, :added_on]
    },
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    :country => {:file => 'TR01_COUNTRY.csv', :fields => [:code, :name, :region, :network_type, nil]},
    # fields: ID	TYPE	TYPE_PROPERTY
    :organization_type => {:file => 'TR02_ORGANIZATION_TYPE.csv', :fields => [nil, :name, :type_property]},
    #fields: SECTOR_NAME	SECTOR_ID	ICB_NUMBER	SUPER_SECTOR
    :sector => {:file => 'TR03_SECTOR.csv', :fields => [:name, :old_id, :icb_number, :parent_id]},
    #fields: COP_SCORE	COP_SCORE_DESCRIPTION
    :cop_score => {:file => 'TR04_COP_SCORE.csv', :fields => [:old_id, :description]},
    # fields: PRINCIPLE_ID	PRINCIPLE_NAME
    :principle => {:file => 'TR05_PRINCIPLE.csv', :fields => [:old_id, :name]},
    # fields: INTEREST_ID	INTEREST_NAME
    :interest  => {:file => 'TR06_INTEREST.csv', :fields => [:old_id, :name]},
    # fields: ROLE_ID ROLE_NAME
    :role      => {:file => 'TR07_ROLE.csv', :fields => [:old_id, :name]},
    #fields LIST_EXCHANGE_CODE	LIST_EXCHANGE_NAME	LIST_SECONDARY_CODE	LIST_TERTIARY_CODE	TR01_COUNTRY_ID
    :exchange => {:file => 'TR08_EXCHANGE.csv', :fields => [:code, :name, :secondary_code, :terciary_code, :country_id]},
    # fields: Listing_ID	Listing_Name
    :listing_status => {:file => 'TR09_LISTING_STATUS.csv', :fields => [:old_id, :name]},
    # fields: LANGUAGE_ID	LANGUAGE_NAME
    :language => {:file => 'TR10_LANGUAGE.csv', :fields => [:old_id, :name]},
    # fields: REASON_ID	REASON_DESCRIPTION
    :removal_reason => {:file => 'TR11_REASON_FOR_REMOVAL.csv', :fields => [:old_id, :description]},
    # fields: ID	NAME	PARENT_ID	DISPLAY_ORDER
    :logo_publication => {:file => 'TR14_LOGO_PUBLICATIONS.csv', :fields => [:old_id, :name, :parent_id, :display_order]},
    # fields: ID	DATE_REQUESTED	DATE_STATUS	PUBLICATION_ID	ORG_ID	CONTACT_ID	REVIEWER_ID	REPLIED_TO
    #             PURPOSE	REQUEST_STATUS	POLICY_ACCEPTED	POLICY_ACCEPTED_DATE
    :logo_request => {:file   => 'TR15_LOGO_REQUESTS.csv',
                      :fields => [:old_id, :requested_on, :status_changed_on, :publication_id, :organization_id,
                                    :contact_id, :reviewer_id, :replied_to, :purpose, :status, :accepted, :accepted_on]},
    # fields: ID	LOGO_NAME	DESCRIPTION	THUMBNAIL	LOGOFILE
    :logo_file => {:file => 'TR18_LOGO_FILES.csv', :fields => [:old_id, :name, :description, :thumbnail, :file]},
    # fields: ID	COMMENT_DATE	LOGO_REQUEST_ID	CONTACT_ID	TEXT
    :logo_comment => {:file => 'TR17_LOGO_COMMENTS.csv', :fields => [:old_id, :added_on, :logo_request_id, :contact_id, :body]},

    #fields: ID	TR02_TYPE	ORG_NAME	SECTOR_ID ORG_NETWORK_BIT	ORG_PARTICIPANT_BIT	ORG_NB_EMPLOY	ORG_URL
    #        ORG_BHR_URL	ORG_DATE_CREATE	ORG_DATE_MODIFICATION	ORG_DATE_JOINING	ORG_DATE_DELISTED	ORG_ACTIVE
    #        ORG_ISGLOBAL500	TR01_COUNTRY_ID	ORG_STATUS_COP	ORG_COP_ALERT	ORG_UN_SPEC	ORG_PART_MAIL
    #        ORG_30DAYS_TO_COP	ORG_90DAYS_TO_COP	ORG_TODAY_COPDUE	ORG_TODAY_INACT	ORG_30DAYS_TO_INACT
    #        ORG_90DAYS_TO_INACT	ORG_MEMBER_ONEYEAR	ORG_LISTED_STATUS	ORG_LIST_CODE	ORG_LIST_EXCHANGE_CODE
    #        ORG_PARENT_NAME	ORG_PARENT_LIST_CODE	TR11_REASON	ORG_LAST_MODIFIED_BY	ORG_JOIN_LETTER
    :organization => {:file   => 'R01_ORGANIZATION.csv',
                      :fields => {
                          "ID"                     => :old_id,
                          "TR02_TYPE"              => :organization_type_id,
                          "ORG_NAME"               => :name,
                          "SECTOR_ID"              => :sector_id,
                          "ORG_NETWORK_BIT"        => :local_network,
                          "ORG_PARTICIPANT_BIT"    => :participant,
                          "ORG_NB_EMPLOY"          => :employees,
                          "ORG_URL"                => :url,
                          "ORG_BHR_URL"            => nil,
                          "ORG_DATE_CREATE"        => :added_on,
                          "ORG_DATE_MODIFICATION"  => :modified_on,
                          "ORG_DATE_JOINING"       => :joined_on,
                          "ORG_DATE_DELISTED"      => :delisted_on,
                          "ORG_ACTIVE"             => :active,
                          "ORG_ISGLOBAL500"        => :is_ft_500,
                          "TR01_COUNTRY_ID"        => :country_id,
                          "ORG_STATUS_COP"         => :cop_status,
                          "ORG_COP_ALERT"          => nil,
                          "ORG_UN_SPEC"            => nil,
                          "ORG_PART_MAIL"          => nil,
                          "ORG_30DAYS_TO_COP"      => nil,
                          "ORG_90DAYS_TO_COP"      => nil,
                          "ORG_TODAY_COPDUE"       => :cop_due_on,
                          "ORG_TODAY_INACT"        => :inactive_on,
                          "ORG_30DAYS_TO_INACT"    => nil,
                          "ORG_90DAYS_TO_INACT"    => nil,
                          "ORG_MEMBER_ONEYEAR"     => :one_year_member_on,
                          "ORG_LISTED_STATUS"      => :listing_status_id,
                          "ORG_LIST_CODE"          => :stock_symbol,
                          "ORG_LIST_EXCHANGE_CODE" => :exchange_id,
                          "ORG_PARENT_NAME"        => nil,
                          "ORG_PARENT_LIST_CODE"   => nil,
                          "TR11_REASON"            => :removal_reason_id,
                          "ORG_LAST_MODIFIED_BY"   => :last_modified_by_id,
                          "ORG_JOIN_LETTER"        => nil
                        }.values
                      
                      },
    # fields: CONTACT_ID	CONTACT_FNAME	CONTACT_MNAME	CONTACT_LNAME	CONTACT_PREFIX	CONTACT_JOB_TITLE	CONTACT_EMAIL
    #         CONTACT_PHONE	CONTACT_MOBILE	CONTACT_FAX	R01_ORG_NAME	CONTACT_ADRESS	CONTACT_CITY	CONTACT_STATE
    #         CONTACT_CODE_POSTAL	TR01_COUNTRY_ID	CONTACT_IS_CEO	CONTACT_IS_CONTACT_POINT	CONTACT_IS_NEWSLETTER
    #         CONTACT_IS_ADVISORY_COUNCIL	CONTACT_LOGIN	CONTACT_PWD	CONTACT_ADDRESS2
    :contact => {:file   => 'R10_CONTACT.csv',
                 :fields => [:old_id, :first_name, :middle_name, :last_name, :prefix, :job_title, :email,
                              :phone, :mobile, :fax, :organization_id, :address, :city, :state,
                              :postal_code, :country_id, :ceo, :contact_point, :newsletter, 
                              :advisory_council, :login, :password, :address_more]},
    # fields: COP_ID	R01_ORG_NAME	COP_TITLE	COP_DOCUMENT_RELATED	COP_CONTACT_EMAIL	COP_PERIOD_START_YEAR	
    #         COP_FACILITATOR	COP_CONTACT_TITLE	COP_PERIOD_START_MONTH	COP_PERIOD_END_MONTH	COP_PERIOD_LINK1
    #         COP_PERIOD_LINK2	COP_PERIOD_LINK3	COP_DATE_CREATE	COP_DATE_MODIFICATION	COP_CONTACT_PERSON
    #         COP_PERIOD_END_YEAR	COP_DOCUMENT_STATUS	COP_CEO_COMMIT_LETTER	COP_DESCRIPTION_ACTIONS	COP_USE_INDICATORS
    #         TR04_SCORE	COP_USE_GRI	COP_HAS_CERTIFICATION	COP_NOTABLE_PROGRAM
    :communication_on_progress => {:file   => 'R02_COM_ON_PROCESS.csv',
                                   :fields => [:identifier, :organization_id, :title, :related_document, :email, :start_year,
                                               :facilitator, :job_title, :start_month, :end_month, :url1,
                                               :url2, :url3, :added_on, :modified_on, :contact_name,
                                               :end_year, :status, :include_ceo_letter, :include_actions, :use_indicators,
                                               :cop_score_id, :use_gri, :has_certification]},
    # fields: CASE_ID	R01_ORG_NAME	CASE_TITLE	CASE_STORY_TYPE	CASE_CATEGORY	CASE_DATE	CASE_DESCRIPTION
    #         CASE_URL_LINK1	CASE_URL_LINK2	CASE_URL_LINK3	CASE_AUTHOR	CASE_AUTHOR_INSTITUTION
    #         CASE_AUTHOR_EMAIL	CASE_AUTHOR2	CASE_AUTHOR2_INSTITUTION	CASE_AUTHOR2_EMAIL	CASE_REVIEWER
    #         CASE_REVIEWER_INSTITUTION	CASE_REVIEWER_EMAIL	CASE_REVIEWER2	CASE_REVIEWER2_INSTITUTION
    #         CASE_REVIEWER2_EMAIL	CASE_FILE	CASE_CONTACT1_NAME	CASE_CONTACT1_EMAIL	CASE_CONTACT2_NAME
    #         CASE_CONTACT2_EMAIL	CASE_STATUS	CASE_DOC_EXT
    :case_story => {:file   => 'R07_CASE_STORY.csv',
                    :fields => [:identifier, :organization_id, :title, nil, :category, :case_date, :description,
                                :url1, :url2, :url3, :author1, :author1_institution,
                                :author1_email, :author2, :author2_institution, :author2_email, :reviewer1,
                                :reviewer1_institution, :reviewer1_email, :reviewer2, :reviewer2_institution,
                                :reviewer2_email, :uploaded, :contact1, :contact1_email, :contact2,
                                :contact2_email, :status, :extension]},
                                
    #fields: "ID","FIRST_NAME","LAST_NAME","ORG_NAME","EMAIL"
    :bulletin_subscriber => {:file  => 'TR20_GCB_SUBSCRIBERS.csv',
                             :fields => [nil, :first_name, :last_name, :organization_name, :email]}
  }
  
  # Imports all the data in files located in options[:folder]
  def run(options={})
    setup(options)
    @files.each{|entry| import(entry, CONFIG[entry])}
    HabtmImporter.new.delete_all_and_run(options) if @run_habtm
  end

  # Imports the data from a single file
  def import(name, options)
    log "Importing #{name}.."
    raise "Unable to find '#{name}' in importer options." unless options
    file = File.join(@data_folder, options[:file])
    model = name.to_s.camelize.constantize
    # read the file
    CSV.foreach(file, :headers => :first_row) do |row|
      # create an object of the correct type and save
      o = model.new
      options[:fields].each_with_index do |field,i|
        next if field.nil?
        # fields that end with _id require a lookup
        if field == :country_id
          found = Country.find_by_code(row[i])
          o.country_id = found.id if found
        elsif field == :parent_id
          if name == :sector
            # sector tree depends on the icb_number field
            o.parent_id = Sector.find_by_icb_number(row[i]).try(:id) if row[i]
          else
            o.parent_id = model.find_by_old_id(row[i]).id if row[i]
          end
        elsif field == :sector_id
          o.sector_id = Sector.find_by_old_id(row[i]).id if row[i]
        elsif field == :exchange_id
          o.exchange_id = Exchange.find_by_code(row[i]).try(:id) if row[i]
        elsif field == :listing_status_id
          o.listing_status_id = ListingStatus.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :publication_id
          o.publication_id = LogoPublication.find_by_old_id(row[i]).id if row[i]
        elsif field == :cop_score_id
          o.cop_score_id = CopScore.find_by_old_id(row[i]).id if row[i]
        elsif field == :logo_request_id
          o.logo_request_id = LogoRequest.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :logo_file_id
          o.logo_file_id = LogoFile.find_by_old_id(row[i]).id if row[i]
        elsif field == :removal_reason_id
          o.removal_reason_id = RemovalReason.find_by_old_id(row[i]).try(:id) if row[i]
        elsif field == :organization_id
          if [:contact, :communication_on_progress, :case_story].include? name
            # some tables are linked to organization by name
            o.organization_id = Organization.find_by_name(row[i].strip).try(:id) if row[i]
          else
            o.organization_id = Organization.find_by_old_id(row[i]).try(:id) if row[i]
          end
        elsif field == :initiative_id and lookup = row[i]
          o.initiative = Initiative.find_by_old_id(lookup)
        elsif [:contact_id, :reviewer_id, :last_modified_by_id].include? field
          o.send("#{field}=", Contact.find_by_old_id(row[i]).try(:id)) if row[i]
        elsif field == :organization_type_id
          o.organization_type_id = OrganizationType.find_by_name(row[i]).try(:id) if row[i]
        elsif field == :category
          # CaseStory.CATEGORY becomes two fields - is_partnership_project and is_internalization_project
          o.is_partnership_project = [1, 3].include?(row[i].to_i)
          o.is_internalization_project = [2, 3].include?(row[i].to_i)
        elsif [:added_on, :modified_on, :joined_on, :delisted_on, :one_year_member_on, :inactive_on, :cop_due_on].include?(field) and lookup = row[i]
          if lookup =~ /\d{4}-\d{2}-\d{2} .*/
            year, month, day = lookup.split(' ').first.split('-')
          else
            month, day, year = lookup.split('/')
          end
          begin
            o.send("#{field}=", Time.mktime(year, month, day).to_date)
          rescue
            log "** [minor error] Could not set #{row[i]} as #{field}"
          end
        else
          value = row[i]
          unless value.blank?
            value = true if value.is_a?(String) && value.downcase == 'true'
            value = false if value.is_a?(String) && value.downcase == 'false'
            value.strip! if value.is_a?(String)
            o.send("#{field}=", value)
          end
        end
      end
      update_state(name, o)
      
      if perform_validation?(name)
        saved = o.save
        log "** [error] Could not save #{name}: #{row} - #{o.errors.full_messages.to_sentence}" unless saved
      else
        begin
          o.save(false)
        rescue
          log "** [error] Could not save #{name}: #{row}"
        end
      end
    end
    log "-- [info] Imported #{model.count} records."
    # call a post_* method for work required after importing a file
    send("post_#{name}") if self.respond_to?("post_#{name}")
  end
  
  def delete_all(options={})
    setup(options)
    @files.each{|entry| entry.to_s.camelize.constantize.delete_all}
  end

  def delete_all_and_run(options={})
    delete_all(options)
    run(options)
  end
  
  # runs after the organization import, pledge amount only exists
  # in the TEMP table/file
  def post_organization
    import_from_temp_table
    convert_organizations_to_local_networks
  end
  
  def post_contact
    assign_roles
    assign_network_managers
    assign_local_network_id
  end
  
  def post_communication_on_progress
    import_cop_xml
  end
  
  def nordic_countries
    ['Denmark', 'Finland', 'Sweden', 'Norway', 'Iceland']
  end

  def gulf_states
    # Saudi Arabia seems mis-spelled?
    ['Bahrain', 'Kuwait', 'Oman', 'Qatar', 'Saudi Arabia', 'Saudia Arabia', 'United Arab Emirates']
  end

  def skip_extraction?(name)
    skip = nordic_countries + gulf_states
    skip.include?(name)
  end

  def get_local_network_organizations
    OrganizationType.for_filter(:gc_networks).first.organizations.find(:all, :conditions => ["local_network = ? AND name LIKE ?", true, 'GC Network - %'])
  end

  def attach_countries_to_network(local_net, organization)
    organization.country.update_attribute :local_network_id, local_net.id
    countries = []
    if local_net.name =~ /Gulf States/
      countries = Country.find(:all, :conditions => ["name IN (?)", gulf_states])
    elsif local_net.name =~ /Nordic/
      countries = Country.find(:all, :conditions => ["name IN (?)", nordic_countries])
    end
    countries.each do |country|
      country.update_attribute :local_network_id, local_net.id
    end
  end

  def convert_organizations_to_local_networks
    get_local_network_organizations.each do |organization|
      name = organization.name.gsub(/GC Network - /, '')
      next if skip_extraction?(name)
      local_net = LocalNetwork.new( :name => name,
                                    :url  => organization.url )
      # 0-No network, 1-Network in Development, 2-Established
      if organization.country.network_type
        local_net.state = ['none', 'emerging', 'established'][organization.country.network_type]
      end
      # we now save the local network and assign the country
      local_net.save
      attach_countries_to_network(local_net, organization)
      # we no longer need the organization, we could "organization.delete" now
    end
  end

  def assign_network_managers
    #fields: COUNTRY_ID	COUNTRY_NAME	COUNTRY_REGION	COUNTRY_NETWORK_TYPE	GC_COUNTRY_MANAGER
    file = File.join(@data_folder, CONFIG[:country][:file])
    CSV.foreach(file, :headers => :first_row) do |row|
      manager = row['GC_COUNTRY_MANAGER']
      unless manager.blank?
        # get country, contact and network
        country = Country.find_by_code(row['COUNTRY_ID'])
        contact = Contact.first(:conditions => {:first_name => manager.split.first,
                                                :last_name  => manager.split.last})
        begin
          network = country.local_network.first
        rescue
          network = nil
        end
        if country && contact && network
          # get network and assign manager
          network.manager_id = contact.id
          network.save
        else
          log "** [minor error] Could not find contact: #{manager}" unless contact
          log "** [minor error] Could not find country: #{row['COUNTRY_ID']}" unless country
          log "** [minor error] Could not find network for: #{row['COUNTRY_ID']}" unless network
        end
      end
    end
  end

  def assign_local_network_id
    return unless LocalNetwork.count > 0
    get_local_network_organizations.each do |organization|
      puts "Working with #{organization.name} ##{organization.id}"
      if organization && contacts = organization.contacts and contacts.any?
        network = organization.country.local_network
        contacts.each do |contact|
          puts "  working with #{contact.name} ##{contact.id}"
          contact.update_attribute :local_network_id, network.id
          puts "  DONE!"
        end
      end
    end
  end  
  
  def import_cop_xml
    require 'hpricot'
    require 'facets'
    puts "*** Importing from cop_xml data..."
    files = Dir[DEFAULTS[:path_to_cop_xml]].map { |f| f - '.xml' }.map {|f| f.split('/').last }
    converter = Iconv.new("UTF-8", "iso8859-1") 
    files.each do |f|
      puts "Working with file #{f}:"
      if cop = CommunicationOnProgress.find_by_identifier(f)
        description = converter.iconv (Hpricot(open("data/cop_xml/#{f}.xml"))/'description').inner_html
        cop.update_attribute :description, description.strip
      else
        puts "  *** Error: Can't find the COP"
      end
      puts "\n"
    end
    puts "*** Done!"
  end
  
  # Imports fields from R01_ORGANIZATION_TEMP.csv:
  #   pledge_amount & id
  def import_from_temp_table
    file = File.join(@data_folder, "R01_ORGANIZATION_TEMP.csv")
    CSV.foreach(file, :headers => :first_row) do |row|
      # get organization by name
      if o = Organization.find_by_name(row["ORG_NAME"])
        # import pledge
        pledge = row["PLEDGE_AMOUNT"]
        o.pledge_amount = pledge.to_i if pledge.to_i > 0
        # import id in TMP table
        old_tmp_id = row["ID"].to_i
        o.old_tmp_id = old_tmp_id if old_tmp_id.to_i > 0
        # save the record
        o.save
      end
    end
  end
  
  def assign_roles
    file = File.join(@data_folder, "R12_XREF_R10_TR07.csv")
    # "ROLE_ID","CONTACT_ID","R01_ORG_NAME"
    CSV.foreach(file, :headers => :first_row) do |row|
      role_id = row['ROLE_ID']
      contact_id = row['CONTACT_ID']
      contact = Contact.find_by_old_id contact_id
      role = Role.find_by_old_id role_id
      if role && contact
        contact.roles << role
      else
        log "** [error] Could not assign role: #{row.inspect}"
      end
    end
  end

  # Creates some instance variables used throughout the application
  # :data_file - folder where the .CVS files are located, default is lib/un7_tables
  # :silent - avoid output statements if true
  # :files - indicates what files you want to import, defaults to all
  # :habtm - runs the HabtmImporter after Importer if set to true
  def setup(options={})
    @data_folder = options[:folder] || File.join(RAILS_ROOT, 'lib/un7_tables')
    @silent = options[:silent] || false
    if options[:files]
      @files = options[:files].is_a?(Array) ? options[:files] : [options[:files]]
    else
      @files = FILES
    end
    # run_habtm default is true if user wants to run the importer for all files
    @run_habtm = options[:run_habtm] || (@files == FILES)
    no_observers
  end

  private
    # translates the old database status into our state fields
    def update_state(name, model)
      case name
        when :logo_request then
          # (0: “Pending Review” 1: “In Review”, 2”:“Declined” or 3:“Accepted)
          model.state = ['pending_review', 'in_review', 'rejected', 'approved'][model.status.to_i]
        when :case_story then
          # Case Story Status. Values( -1: “Rejected”, 0:”In Review”, 1:”Accepted”
          model.state = ['rejected', 'in_review', 'approved'][model.status.to_i + 1]
        when :organization then
          # all organizations in R01_ORGANIZATION were approved
          model.state = 'approved'
          # COP state - 2=Active, 1=Non-communicating, 0=Inactive, 3=Delisted
          model.cop_state = ['inactive','non-communicating','active','delisted'][model.cop_status.to_i]
        when :communication_on_progress then
          # COP Status (0: “In review”, 1: “Published”, -1: “Rejected”)
          model.state = ['rejected', 'in_review', 'approved'][model.status.to_i + 1]
      end
    end
    
    def perform_validation?(name)
      name != :logo_comment
    end
    
    def no_observers
      # We don't want observers to be called on import
      unless RAILS_ENV == 'test'
        # if we delete observers when running test, other tests fail
        Organization.delete_observers
        LogoComment.delete_observers
      end
    end
    
    def log(string)
      puts(string) unless @silent
    end
end