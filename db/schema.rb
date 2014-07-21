# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140310192642) do

  create_table "announcements", :force => true do |t|
    t.integer  "local_network_id"
    t.integer  "principle_id"
    t.string   "title"
    t.string   "description"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annual_reports", :force => true do |t|
    t.integer  "local_network_id"
    t.date     "year"
    t.boolean  "future_plans"
    t.boolean  "activities"
    t.boolean  "financials"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", :force => true do |t|
    t.string   "full_name"
    t.string   "acronym"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "authors_resources", :id => false, :force => true do |t|
    t.integer  "author_id"
    t.integer  "resource_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "awards", :force => true do |t|
    t.integer  "local_network_id"
    t.string   "title"
    t.text     "description"
    t.string   "award_type"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "case_stories", :force => true do |t|
    t.string   "identifier"
    t.integer  "organization_id"
    t.string   "title"
    t.date     "case_date"
    t.string   "url1"
    t.string   "url2"
    t.string   "url3"
    t.string   "author1"
    t.string   "author1_institution"
    t.string   "author1_email"
    t.string   "author2"
    t.string   "author2_institution"
    t.string   "author2_email"
    t.string   "reviewer1"
    t.string   "reviewer1_institution"
    t.string   "reviewer1_email"
    t.string   "reviewer2"
    t.string   "reviewer2_institution"
    t.string   "reviewer2_email"
    t.boolean  "uploaded"
    t.string   "contact1"
    t.string   "contact1_email"
    t.string   "contact2"
    t.string   "contact2_email"
    t.integer  "status"
    t.string   "extension"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_partnership_project"
    t.boolean  "is_internalization_project"
    t.string   "state"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.integer  "contact_id"
    t.text     "description"
    t.boolean  "replied_to"
    t.integer  "reviewer_id"
  end

  create_table "case_stories_countries", :id => false, :force => true do |t|
    t.integer "case_story_id"
    t.integer "country_id"
  end

  create_table "case_stories_principles", :id => false, :force => true do |t|
    t.integer "case_story_id"
    t.integer "principle_id"
  end

  create_table "comments", :force => true do |t|
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["commentable_type"], :name => "index_comments_on_commentable_type"
  add_index "comments", ["contact_id"], :name => "index_comments_on_contact_id"

  create_table "communication_on_progresses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "title"
    t.string   "contact_info"
    t.boolean  "include_actions"
    t.boolean  "include_measurement"
    t.boolean  "use_indicators"
    t.integer  "cop_score_id"
    t.boolean  "use_gri"
    t.boolean  "has_certification"
    t.boolean  "notable_program"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "state"
    t.boolean  "include_continued_support_statement"
    t.string   "format"
    t.boolean  "references_human_rights"
    t.boolean  "references_labour"
    t.boolean  "references_environment"
    t.boolean  "references_anti_corruption"
    t.boolean  "meets_advanced_criteria"
    t.boolean  "additional_questions"
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "method_shared"
    t.string   "differentiation"
    t.boolean  "references_business_peace"
    t.boolean  "references_water_mandate"
    t.string   "cop_type"
    t.date     "published_on"
  end

  add_index "communication_on_progresses", ["created_at"], :name => "index_communication_on_progresses_on_created_at"
  add_index "communication_on_progresses", ["differentiation"], :name => "index_communication_on_progresses_on_differentiation"
  add_index "communication_on_progresses", ["organization_id"], :name => "index_communication_on_progresses_on_organization_id"
  add_index "communication_on_progresses", ["state"], :name => "index_communication_on_progresses_on_state"

  create_table "communication_on_progresses_countries", :id => false, :force => true do |t|
    t.integer "communication_on_progress_id"
    t.integer "country_id"
  end

  create_table "communication_on_progresses_languages", :id => false, :force => true do |t|
    t.integer "communication_on_progress_id"
    t.integer "language_id"
  end

  create_table "communication_on_progresses_principles", :id => false, :force => true do |t|
    t.integer "communication_on_progress_id"
    t.integer "principle_id"
  end

  create_table "communications", :force => true do |t|
    t.integer "local_network_id"
    t.string  "title"
    t.string  "communication_type"
    t.date    "date"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "old_id"
    t.string   "first_name"
    t.string   "middle_name"
    t.string   "last_name"
    t.string   "prefix"
    t.string   "job_title"
    t.string   "email"
    t.string   "phone"
    t.string   "mobile"
    t.string   "fax"
    t.integer  "organization_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.integer  "country_id"
    t.string   "username"
    t.string   "address_more"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token"
    t.integer  "local_network_id"
    t.string   "encrypted_password"
    t.string   "plaintext_password"
    t.string   "reset_password_token"
    t.datetime "last_sign_in_at"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             :default => 0
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "welcome_package"
  end

  add_index "contacts", ["organization_id"], :name => "index_contacts_on_organization_id"

  create_table "contacts_roles", :id => false, :force => true do |t|
    t.integer "contact_id"
    t.integer "role_id"
  end

  create_table "cop_answers", :force => true do |t|
    t.integer  "cop_id"
    t.integer  "cop_attribute_id"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text",             :null => false
  end

  add_index "cop_answers", ["cop_id"], :name => "index_cop_answers_on_cop_id"

  create_table "cop_attributes", :force => true do |t|
    t.integer  "cop_question_id"
    t.string   "text"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hint",                               :null => false
    t.boolean  "open",            :default => false
  end

  add_index "cop_attributes", ["cop_question_id", "position"], :name => "index_cop_attributes_on_cop_question_id_and_position"

  create_table "cop_files", :force => true do |t|
    t.integer  "cop_id"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type"
    t.integer  "language_id"
  end

  create_table "cop_links", :force => true do |t|
    t.integer  "cop_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type"
    t.integer  "language_id"
  end

  create_table "cop_questions", :force => true do |t|
    t.integer  "principle_area_id"
    t.string   "text"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id"
    t.string   "grouping"
    t.string   "implementation"
    t.integer  "year"
  end

  add_index "cop_questions", ["principle_area_id", "position"], :name => "index_cop_questions_on_principle_area_id_and_position"

  create_table "cop_scores", :force => true do |t|
    t.string   "description"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "region"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.integer  "local_network_id"
    t.integer  "participant_manager_id"
  end

  add_index "countries", ["participant_manager_id"], :name => "index_countries_on_participant_manager_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "starts_on"
    t.date     "ends_on"
    t.text     "location"
    t.integer  "country_id"
    t.text     "urls"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.string   "approval"
  end

  create_table "events_principles", :id => false, :force => true do |t|
    t.integer "event_id"
    t.integer "principle_area_id"
  end

  create_table "exchanges", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "secondary_code"
    t.string   "terciary_code"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headlines", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.string   "location"
    t.date     "published_on"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "approval"
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "headlines", ["approval"], :name => "index_headlines_on_approval"
  add_index "headlines", ["published_on"], :name => "index_headlines_on_published_on"

  create_table "initiatives", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "integrity_measures", :force => true do |t|
    t.integer "local_network_id"
    t.string  "title"
    t.string  "policy_type"
    t.text    "description"
    t.date    "date"
  end

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_statuses", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "local_network_events", :force => true do |t|
    t.integer  "local_network_id"
    t.string   "title"
    t.text     "description"
    t.date     "date"
    t.string   "event_type"
    t.integer  "num_participants"
    t.integer  "gc_participant_percentage"
    t.boolean  "stakeholder_company"
    t.boolean  "stakeholder_sme"
    t.boolean  "stakeholder_business_association"
    t.boolean  "stakeholder_labour"
    t.boolean  "stakeholder_un_agency"
    t.boolean  "stakeholder_ngo"
    t.boolean  "stakeholder_foundation"
    t.boolean  "stakeholder_academic"
    t.boolean  "stakeholder_government"
    t.boolean  "stakeholder_media"
    t.boolean  "stakeholder_others"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.string   "region"
    t.text     "file_content"
  end

  create_table "local_network_events_principles", :id => false, :force => true do |t|
    t.integer "local_network_event_id"
    t.integer "principle_id"
  end

  add_index "local_network_events_principles", ["local_network_event_id"], :name => "index_local_network_events_principles_on_local_network_event_id"
  add_index "local_network_events_principles", ["principle_id"], :name => "index_local_network_events_principles_on_principle_id"

  create_table "local_networks", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "sg_global_compact_launch_date"
    t.date     "sg_local_network_launch_date"
    t.boolean  "sg_annual_meeting_appointments"
    t.integer  "sg_annual_meeting_appointments_file_id"
    t.boolean  "sg_selected_appointees_local_network_representative"
    t.boolean  "sg_selected_appointees_steering_committee"
    t.boolean  "sg_selected_appointees_contact_point"
    t.boolean  "sg_established_as_a_legal_entity"
    t.integer  "sg_established_as_a_legal_entity_file_id"
    t.boolean  "membership_subsidiaries"
    t.integer  "membership_companies"
    t.integer  "membership_sme"
    t.integer  "membership_micro_enterprise"
    t.integer  "membership_business_organizations"
    t.integer  "membership_csr_organizations"
    t.integer  "membership_labour_organizations"
    t.integer  "membership_civil_societies"
    t.integer  "membership_academic_institutions"
    t.integer  "membership_government"
    t.integer  "membership_other"
    t.boolean  "fees_participant"
    t.integer  "fees_amount_company"
    t.integer  "fees_amount_sme"
    t.integer  "fees_amount_other_organization"
    t.integer  "fees_amount_participant"
    t.integer  "fees_amount_voluntary_private"
    t.integer  "fees_amount_voluntary_public"
    t.boolean  "stakeholder_company"
    t.boolean  "stakeholder_sme"
    t.boolean  "stakeholder_business_association"
    t.boolean  "stakeholder_labour"
    t.boolean  "stakeholder_un_agency"
    t.boolean  "stakeholder_ngo"
    t.boolean  "stakeholder_foundation"
    t.boolean  "stakeholder_academic"
    t.boolean  "stakeholder_government"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "linkedin"
    t.string   "funding_model"
  end

  create_table "logo_comments", :force => true do |t|
    t.date     "added_on"
    t.integer  "old_id"
    t.integer  "logo_request_id"
    t.integer  "contact_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.string   "attachment_content_type"
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "logo_files", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "old_id"
    t.string   "thumbnail"
    t.string   "file"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_file_name"
    t.string   "zip_content_type"
    t.integer  "zip_file_size"
    t.datetime "zip_updated_at"
    t.string   "preview_file_name"
    t.string   "preview_content_type"
    t.integer  "preview_file_size"
    t.datetime "preview_updated_at"
  end

  create_table "logo_files_logo_requests", :id => false, :force => true do |t|
    t.integer "logo_file_id"
    t.integer "logo_request_id"
  end

  create_table "logo_publications", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.integer  "parent_id"
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logo_requests", :force => true do |t|
    t.integer  "old_id"
    t.integer  "publication_id"
    t.integer  "organization_id"
    t.integer  "contact_id"
    t.integer  "reviewer_id"
    t.boolean  "replied_to"
    t.string   "purpose"
    t.boolean  "accepted"
    t.date     "accepted_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.date     "approved_on"
  end

  create_table "meetings", :force => true do |t|
    t.integer  "local_network_id"
    t.string   "meeting_type"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mous", :force => true do |t|
    t.integer  "local_network_id"
    t.date     "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mou_type"
  end

  create_table "non_business_organization_registrations", :force => true do |t|
    t.date    "date"
    t.string  "place"
    t.string  "authority"
    t.string  "number"
    t.text    "mission_statement"
    t.integer "organization_id"
  end

  add_index "non_business_organization_registrations", ["organization_id"], :name => "index_non_business_organization_registrations_on_organization_id"

  create_table "organization_types", :force => true do |t|
    t.string   "name"
    t.integer  "type_property"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", :force => true do |t|
    t.integer  "old_id"
    t.string   "name"
    t.integer  "organization_type_id"
    t.integer  "sector_id"
    t.boolean  "participant"
    t.integer  "employees"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "joined_on"
    t.date     "delisted_on"
    t.boolean  "active"
    t.integer  "country_id"
    t.string   "stock_symbol"
    t.integer  "removal_reason_id"
    t.integer  "last_modified_by_id"
    t.string   "state"
    t.integer  "exchange_id"
    t.integer  "listing_status_id"
    t.boolean  "is_ft_500"
    t.date     "cop_due_on"
    t.date     "inactive_on"
    t.string   "commitment_letter_file_name"
    t.string   "commitment_letter_content_type"
    t.integer  "commitment_letter_file_size"
    t.datetime "commitment_letter_updated_at"
    t.integer  "pledge_amount"
    t.string   "cop_state"
    t.boolean  "replied_to"
    t.integer  "reviewer_id"
    t.string   "bhr_url"
    t.date     "rejected_on"
    t.date     "network_review_on"
    t.integer  "revenue"
    t.date     "rejoined_on"
    t.date     "non_comm_dialogue_on"
    t.string   "review_reason"
    t.integer  "participant_manager_id"
    t.boolean  "is_local_network_member"
    t.boolean  "is_landmine"
    t.boolean  "is_tobacco"
    t.string   "no_pledge_reason"
  end

  add_index "organizations", ["country_id"], :name => "index_organizations_on_country_id"
  add_index "organizations", ["participant"], :name => "index_organizations_on_participant"
  add_index "organizations", ["participant_manager_id"], :name => "index_organizations_on_participant_manager_id"

  create_table "page_groups", :force => true do |t|
    t.string   "name"
    t.boolean  "display_in_navigation"
    t.string   "html_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "path_stub"
  end

  create_table "pages", :force => true do |t|
    t.string   "path"
    t.string   "title"
    t.string   "html_code"
    t.text     "content"
    t.integer  "parent_id"
    t.integer  "position"
    t.boolean  "display_in_navigation"
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.boolean  "dynamic_content"
    t.integer  "version_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.string   "approval"
    t.boolean  "top_level"
    t.string   "change_path"
  end

  add_index "pages", ["approval"], :name => "index_pages_on_approval"
  add_index "pages", ["group_id"], :name => "index_pages_on_group_id"
  add_index "pages", ["parent_id"], :name => "index_pages_on_parent_id"
  add_index "pages", ["path"], :name => "index_pages_on_path"
  add_index "pages", ["version_number"], :name => "index_pages_on_version_number"

  create_table "principles", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "parent_id"
    t.string   "reference"
  end

  create_table "principles_resources", :id => false, :force => true do |t|
    t.integer  "principle_id"
    t.integer  "resource_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "removal_reasons", :force => true do |t|
    t.string   "description"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "resource_links", :force => true do |t|
    t.string   "url"
    t.string   "title"
    t.string   "link_type"
    t.integer  "resource_id"
    t.integer  "language_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "views",       :default => 0
  end

  create_table "resources", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.date     "year"
    t.string   "isbn"
    t.string   "approval"
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
    t.integer  "views",              :default => 0
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id"
    t.string   "description"
    t.integer  "position"
  end

  create_table "searchables", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.string   "url"
    t.string   "document_type"
    t.datetime "last_indexed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",             :default => true, :null => false
    t.datetime "object_created_at"
    t.datetime "object_updated_at"
  end

  create_table "sectors", :force => true do |t|
    t.string   "name"
    t.integer  "old_id"
    t.string   "icb_number"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "signings", :force => true do |t|
    t.integer  "old_id"
    t.integer  "initiative_id"
    t.integer  "organization_id"
    t.date     "added_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uploaded_files", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name"
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type"
    t.datetime "attachment_updated_at"
    t.string   "attachment_unmodified_filename"
    t.string   "attachable_key"
  end

end
