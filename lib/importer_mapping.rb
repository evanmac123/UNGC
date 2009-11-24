module ImporterMapping
  FILES = [:country, :organization_type, :sector, :exchange, :listing_status, :language, :removal_reason,
            :cop_score, :principle, :role, :organization, :contact, :communication_on_progress,
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
end