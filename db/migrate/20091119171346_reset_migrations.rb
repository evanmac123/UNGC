class ResetMigrations < ActiveRecord::Migration
  def self.up
    create_table "bulletin_subscribers", :force => true do |t|
      t.string   "first_name"
      t.string   "last_name"
      t.string   "organization_name"
      t.string   "email"
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
      t.string   "identifier"
      t.integer  "organization_id"
      t.string   "title"
      t.string   "related_document"
      t.string   "email"
      t.integer  "start_year"
      t.string   "facilitator"
      t.string   "job_title"
      t.integer  "start_month"
      t.integer  "end_month"
      t.string   "url1"
      t.string   "url2"
      t.string   "url3"
      t.date     "added_on"
      t.date     "modified_on"
      t.string   "contact_name"
      t.integer  "end_year"
      t.integer  "status"
      t.boolean  "include_ceo_letter"
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
      t.boolean  "support_statement_signed"
      t.boolean  "support_statement_lists_reason"
      t.boolean  "support_statement_mentions_engagements"
      t.string   "format"
      t.boolean  "references_human_rights"
      t.boolean  "references_labour"
      t.boolean  "references_environment"
      t.boolean  "references_anti_corruption"
      t.boolean  "measures_human_rights_outcomes"
      t.boolean  "measures_labour_outcomes"
      t.boolean  "measures_environment_outcomes"
      t.boolean  "measures_anti_corruption_outcomes"
      t.boolean  "replied_to"
      t.integer  "reviewer_id"
    end

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
      t.boolean  "ceo"
      t.boolean  "contact_point"
      t.boolean  "newsletter"
      t.boolean  "advisory_council"
      t.string   "login"
      t.string   "address_more"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "remember_token_expires_at"
      t.string   "remember_token"
      t.integer  "local_network_id"
      t.string   "hashed_password"
      t.string   "password"
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
    end

    add_index "cop_answers", ["cop_id"], :name => "index_cop_answers_on_cop_id"

    create_table "cop_attributes", :force => true do |t|
      t.integer  "cop_question_id"
      t.string   "text"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "cop_attributes", ["cop_question_id", "position"], :name => "index_cop_attributes_on_cop_question_id_and_position"

    create_table "cop_files", :force => true do |t|
      t.integer  "cop_id"
      t.string   "name"
      t.string   "attachment_file_name"
      t.string   "attachment_content_type"
      t.integer  "attachment_file_size"
      t.datetime "attachment_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cop_links", :force => true do |t|
      t.integer  "cop_id"
      t.string   "name"
      t.string   "url"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "cop_questions", :force => true do |t|
      t.integer  "principle_area_id"
      t.string   "text"
      t.boolean  "area_selected"
      t.integer  "position"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "initiative_id"
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
      t.integer  "network_type"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "manager_id"
      t.integer  "local_network_id"
    end

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

    create_table "interests", :force => true do |t|
      t.string   "name"
      t.integer  "old_id"
      t.datetime "created_at"
      t.datetime "updated_at"
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

    create_table "local_networks", :force => true do |t|
      t.string   "name"
      t.integer  "manager_id"
      t.string   "url"
      t.string   "state"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "code"
    end

    add_index "local_networks", ["code"], :name => "index_local_networks_on_code"

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
      t.date     "requested_on"
      t.date     "status_changed_on"
      t.integer  "publication_id"
      t.integer  "organization_id"
      t.integer  "contact_id"
      t.integer  "reviewer_id"
      t.boolean  "replied_to"
      t.string   "purpose"
      t.string   "status"
      t.boolean  "accepted"
      t.date     "accepted_on"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "state"
    end

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
      t.boolean  "local_network"
      t.boolean  "participant"
      t.integer  "employees"
      t.string   "url"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.date     "added_on"
      t.date     "modified_on"
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
      t.integer  "cop_status"
      t.date     "cop_due_on"
      t.date     "inactive_on"
      t.string   "one_year_member_on"
      t.string   "commitment_letter_file_name"
      t.string   "commitment_letter_content_type"
      t.integer  "commitment_letter_file_size"
      t.datetime "commitment_letter_updated_at"
      t.integer  "pledge_amount"
      t.integer  "old_tmp_id"
      t.string   "cop_state"
      t.boolean  "replied_to"
      t.integer  "reviewer_id"
    end

    add_index "organizations", ["country_id"], :name => "index_organizations_on_country_id"

    create_table "page_groups", :force => true do |t|
      t.string   "name"
      t.boolean  "display_in_navigation"
      t.string   "html_code"
      t.datetime "created_at"
      t.datetime "updated_at"
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
    end

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
    end

    create_table "removal_reasons", :force => true do |t|
      t.string   "description"
      t.integer  "old_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "roles", :force => true do |t|
      t.string   "name"
      t.integer  "old_id"
      t.datetime "created_at"
      t.datetime "updated_at"
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
      t.integer  "size"
      t.string   "content_type"
      t.string   "filename"
      t.integer  "attachable_id"
      t.string   "attachable_type"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end

  def self.down
  end
end
