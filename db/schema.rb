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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150712213420) do

  create_table "announcements", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4
    t.integer  "principle_id",     limit: 4
    t.string   "title",            limit: 255
    t.string   "description",      limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annual_reports", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4
    t.date     "year"
    t.boolean  "future_plans",     limit: 1
    t.boolean  "activities",       limit: 1
    t.boolean  "financials",       limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authors", force: :cascade do |t|
    t.string   "full_name",  limit: 255
    t.string   "acronym",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "authors_resources", id: false, force: :cascade do |t|
    t.integer  "author_id",   limit: 4
    t.integer  "resource_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "awards", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4
    t.string   "title",            limit: 255
    t.text     "description",      limit: 65535
    t.string   "award_type",       limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string   "campaign_id",   limit: 255,                 null: false
    t.string   "name",          limit: 255,                 null: false
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "initiative_id", limit: 4
    t.boolean  "is_deleted",    limit: 1,   default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_private",    limit: 1,   default: false
  end

  add_index "campaigns", ["campaign_id"], name: "index_campaigns_on_campaign_id", unique: true, using: :btree
  add_index "campaigns", ["initiative_id"], name: "index_campaigns_on_initiative_id", using: :btree

  create_table "case_examples", force: :cascade do |t|
    t.string   "company",           limit: 255
    t.integer  "country_id",        limit: 4
    t.boolean  "is_participant",    limit: 1
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "case_examples", ["country_id"], name: "index_case_examples_on_country_id", using: :btree

  create_table "case_stories", force: :cascade do |t|
    t.string   "identifier",                 limit: 255
    t.integer  "organization_id",            limit: 4
    t.string   "title",                      limit: 255
    t.date     "case_date"
    t.string   "url1",                       limit: 255
    t.string   "url2",                       limit: 255
    t.string   "url3",                       limit: 255
    t.string   "author1",                    limit: 255
    t.string   "author1_institution",        limit: 255
    t.string   "author1_email",              limit: 255
    t.string   "author2",                    limit: 255
    t.string   "author2_institution",        limit: 255
    t.string   "author2_email",              limit: 255
    t.string   "reviewer1",                  limit: 255
    t.string   "reviewer1_institution",      limit: 255
    t.string   "reviewer1_email",            limit: 255
    t.string   "reviewer2",                  limit: 255
    t.string   "reviewer2_institution",      limit: 255
    t.string   "reviewer2_email",            limit: 255
    t.boolean  "uploaded",                   limit: 1
    t.string   "contact1",                   limit: 255
    t.string   "contact1_email",             limit: 255
    t.string   "contact2",                   limit: 255
    t.string   "contact2_email",             limit: 255
    t.integer  "status",                     limit: 4
    t.string   "extension",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_partnership_project",     limit: 1
    t.boolean  "is_internalization_project", limit: 1
    t.string   "state",                      limit: 255
    t.string   "attachment_file_name",       limit: 255
    t.string   "attachment_content_type",    limit: 255
    t.integer  "attachment_file_size",       limit: 4
    t.datetime "attachment_updated_at"
    t.integer  "contact_id",                 limit: 4
    t.text     "description",                limit: 65535
    t.boolean  "replied_to",                 limit: 1
    t.integer  "reviewer_id",                limit: 4
  end

  create_table "case_stories_countries", id: false, force: :cascade do |t|
    t.integer "case_story_id", limit: 4
    t.integer "country_id",    limit: 4
  end

  create_table "case_stories_principles", id: false, force: :cascade do |t|
    t.integer "case_story_id", limit: 4
    t.integer "principle_id",  limit: 4
  end

  create_table "comments", force: :cascade do |t|
    t.text     "body",                    limit: 65535
    t.integer  "commentable_id",          limit: 4
    t.string   "commentable_type",        limit: 255
    t.integer  "contact_id",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["contact_id"], name: "index_comments_on_contact_id", using: :btree

  create_table "communication_on_progresses", force: :cascade do |t|
    t.integer  "organization_id",                     limit: 4
    t.string   "title",                               limit: 255
    t.string   "contact_info",                        limit: 255
    t.boolean  "include_actions",                     limit: 1
    t.boolean  "include_measurement",                 limit: 1
    t.boolean  "use_indicators",                      limit: 1
    t.integer  "cop_score_id",                        limit: 4
    t.boolean  "use_gri",                             limit: 1
    t.boolean  "has_certification",                   limit: 1
    t.boolean  "notable_program",                     limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description",                         limit: 65535
    t.string   "state",                               limit: 255
    t.boolean  "include_continued_support_statement", limit: 1
    t.string   "format",                              limit: 255
    t.boolean  "references_human_rights",             limit: 1
    t.boolean  "references_labour",                   limit: 1
    t.boolean  "references_environment",              limit: 1
    t.boolean  "references_anti_corruption",          limit: 1
    t.boolean  "meets_advanced_criteria",             limit: 1
    t.boolean  "additional_questions",                limit: 1
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "method_shared",                       limit: 255
    t.string   "differentiation",                     limit: 255
    t.boolean  "references_business_peace",           limit: 1
    t.boolean  "references_water_mandate",            limit: 1
    t.string   "cop_type",                            limit: 255
    t.date     "published_on"
  end

  add_index "communication_on_progresses", ["created_at"], name: "index_communication_on_progresses_on_created_at", using: :btree
  add_index "communication_on_progresses", ["differentiation"], name: "index_communication_on_progresses_on_differentiation", using: :btree
  add_index "communication_on_progresses", ["organization_id"], name: "index_communication_on_progresses_on_organization_id", using: :btree
  add_index "communication_on_progresses", ["state"], name: "index_communication_on_progresses_on_state", using: :btree

  create_table "communication_on_progresses_countries", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id", limit: 4
    t.integer "country_id",                   limit: 4
  end

  create_table "communication_on_progresses_languages", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id", limit: 4
    t.integer "language_id",                  limit: 4
  end

  create_table "communication_on_progresses_principles", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id", limit: 4
    t.integer "principle_id",                 limit: 4
  end

  create_table "communications", force: :cascade do |t|
    t.integer "local_network_id",   limit: 4
    t.string  "title",              limit: 255
    t.string  "communication_type", limit: 255
    t.date    "date"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "old_id",                    limit: 4
    t.string   "first_name",                limit: 255
    t.string   "middle_name",               limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "prefix",                    limit: 255
    t.string   "job_title",                 limit: 255
    t.string   "email",                     limit: 255
    t.string   "phone",                     limit: 255
    t.string   "mobile",                    limit: 255
    t.string   "fax",                       limit: 255
    t.integer  "organization_id",           limit: 4
    t.string   "address",                   limit: 255
    t.string   "city",                      limit: 255
    t.string   "state",                     limit: 255
    t.string   "postal_code",               limit: 255
    t.integer  "country_id",                limit: 4
    t.string   "username",                  limit: 255
    t.string   "address_more",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token",            limit: 255
    t.integer  "local_network_id",          limit: 4
    t.string   "encrypted_password",        limit: 255
    t.string   "plaintext_password",        limit: 255
    t.string   "reset_password_token",      limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.boolean  "welcome_package",           limit: 1
    t.string   "image_file_name",           limit: 255
    t.string   "image_content_type",        limit: 255
    t.integer  "image_file_size",           limit: 4
    t.datetime "image_updated_at"
  end

  add_index "contacts", ["organization_id"], name: "index_contacts_on_organization_id", using: :btree

  create_table "contacts_roles", id: false, force: :cascade do |t|
    t.integer "contact_id", limit: 4
    t.integer "role_id",    limit: 4
  end

  add_index "contacts_roles", ["contact_id"], name: "index_contacts_roles_on_contact_id", using: :btree
  add_index "contacts_roles", ["role_id"], name: "index_contacts_roles_on_role_id", using: :btree

  create_table "contribution_descriptions", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4,     null: false
    t.text     "pledge",           limit: 65535
    t.text     "pledge_continued", limit: 65535
    t.text     "payment",          limit: 65535
    t.text     "contact",          limit: 65535
    t.text     "additional",       limit: 65535
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "contribution_descriptions", ["local_network_id"], name: "index_contribution_descriptions_on_local_network_id", using: :btree

  create_table "contribution_levels", force: :cascade do |t|
    t.integer  "contribution_levels_info_id", limit: 4,   null: false
    t.string   "description",                 limit: 255, null: false
    t.string   "amount",                      limit: 255, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "order",                       limit: 4
  end

  add_index "contribution_levels", ["contribution_levels_info_id"], name: "index_contribution_levels_on_contribution_levels_info_id", using: :btree
  add_index "contribution_levels", ["order"], name: "index_contribution_levels_on_order", using: :btree

  create_table "contribution_levels_infos", force: :cascade do |t|
    t.integer  "local_network_id",   limit: 4
    t.string   "level_description",  limit: 255
    t.string   "amount_description", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "contribution_levels_infos", ["local_network_id"], name: "index_contribution_levels_infos_on_local_network_id", using: :btree

  create_table "contributions", force: :cascade do |t|
    t.string   "contribution_id",    limit: 255,                 null: false
    t.string   "invoice_code",       limit: 255
    t.integer  "raw_amount",         limit: 4
    t.integer  "recognition_amount", limit: 4
    t.date     "date",                                           null: false
    t.string   "stage",              limit: 255,                 null: false
    t.string   "payment_type",       limit: 255
    t.integer  "organization_id",    limit: 4,                   null: false
    t.string   "campaign_id",        limit: 255
    t.boolean  "is_deleted",         limit: 1,   default: false, null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "contributions", ["campaign_id"], name: "index_contributions_on_campaign_id", using: :btree
  add_index "contributions", ["contribution_id"], name: "index_contributions_on_contribution_id", unique: true, using: :btree
  add_index "contributions", ["organization_id"], name: "index_contributions_on_organization_id", using: :btree

  create_table "cop_answers", force: :cascade do |t|
    t.integer  "cop_id",           limit: 4
    t.integer  "cop_attribute_id", limit: 4
    t.boolean  "value",            limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text",             limit: 65535, null: false
  end

  add_index "cop_answers", ["cop_id"], name: "index_cop_answers_on_cop_id", using: :btree

  create_table "cop_attributes", force: :cascade do |t|
    t.integer  "cop_question_id", limit: 4
    t.string   "text",            limit: 255
    t.integer  "position",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hint",            limit: 65535,                 null: false
    t.boolean  "open",            limit: 1,     default: false
  end

  add_index "cop_attributes", ["cop_question_id", "position"], name: "index_cop_attributes_on_cop_question_id_and_position", using: :btree

  create_table "cop_files", force: :cascade do |t|
    t.integer  "cop_id",                  limit: 4
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type",         limit: 255
    t.integer  "language_id",             limit: 4
  end

  create_table "cop_links", force: :cascade do |t|
    t.integer  "cop_id",          limit: 4
    t.string   "url",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type", limit: 255
    t.integer  "language_id",     limit: 4
  end

  create_table "cop_questions", force: :cascade do |t|
    t.integer  "principle_area_id", limit: 4
    t.string   "text",              limit: 255
    t.integer  "position",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id",     limit: 4
    t.string   "grouping",          limit: 255
    t.string   "implementation",    limit: 255
    t.integer  "year",              limit: 4
  end

  add_index "cop_questions", ["principle_area_id", "position"], name: "index_cop_questions_on_principle_area_id_and_position", using: :btree

  create_table "cop_scores", force: :cascade do |t|
    t.string   "description", limit: 255
    t.integer  "old_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string   "code",                   limit: 255
    t.string   "name",                   limit: 255
    t.string   "region",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id",             limit: 4
    t.integer  "local_network_id",       limit: 4
    t.integer  "participant_manager_id", limit: 4
    t.integer  "regional_center_id",     limit: 4
  end

  add_index "countries", ["participant_manager_id"], name: "index_countries_on_participant_manager_id", using: :btree

  create_table "event_sponsors", force: :cascade do |t|
    t.integer "event_id",   limit: 4
    t.integer "sponsor_id", limit: 4
  end

  add_index "event_sponsors", ["event_id"], name: "index_event_sponsors_on_event_id", using: :btree
  add_index "event_sponsors", ["sponsor_id"], name: "index_event_sponsors_on_sponsor_id", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title",                        limit: 255
    t.text     "description",                  limit: 65535
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "location",                     limit: 65535
    t.integer  "country_id",                   limit: 4
    t.integer  "created_by_id",                limit: 4
    t.integer  "updated_by_id",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved_at"
    t.integer  "approved_by_id",               limit: 4
    t.string   "approval",                     limit: 255
    t.boolean  "is_all_day",                   limit: 1
    t.boolean  "is_online",                    limit: 1
    t.boolean  "is_invitation_only",           limit: 1
    t.integer  "priority",                     limit: 4,     default: 1
    t.integer  "contact_id",                   limit: 4
    t.string   "thumbnail_image_file_name",    limit: 255
    t.string   "thumbnail_image_content_type", limit: 255
    t.integer  "thumbnail_image_file_size",    limit: 4
    t.datetime "thumbnail_image_updated_at"
    t.string   "banner_image_file_name",       limit: 255
    t.string   "banner_image_content_type",    limit: 255
    t.integer  "banner_image_file_size",       limit: 4
    t.datetime "banner_image_updated_at"
    t.string   "call_to_action_1_label",       limit: 255
    t.string   "call_to_action_1_url",         limit: 255
    t.string   "call_to_action_2_label",       limit: 255
    t.string   "call_to_action_2_url",         limit: 255
    t.text     "overview_description",         limit: 65535
    t.text     "media_description",            limit: 65535
    t.string   "tab_1_title",                  limit: 255
    t.text     "tab_1_description",            limit: 65535
    t.string   "tab_2_title",                  limit: 255
    t.text     "tab_2_description",            limit: 65535
    t.string   "tab_3_title",                  limit: 255
    t.text     "tab_3_description",            limit: 65535
    t.text     "sponsors_description",         limit: 65535
  end

  add_index "events", ["contact_id"], name: "index_events_on_contact_id", using: :btree

  create_table "events_principles", id: false, force: :cascade do |t|
    t.integer "event_id",          limit: 4
    t.integer "principle_area_id", limit: 4
  end

  create_table "exchanges", force: :cascade do |t|
    t.string   "code",           limit: 255
    t.string   "name",           limit: 255
    t.string   "secondary_code", limit: 255
    t.string   "terciary_code",  limit: 255
    t.integer  "country_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headlines", force: :cascade do |t|
    t.string   "title",          limit: 255
    t.text     "description",    limit: 65535
    t.string   "location",       limit: 255
    t.date     "published_on"
    t.integer  "created_by_id",  limit: 4
    t.integer  "updated_by_id",  limit: 4
    t.string   "approval",       limit: 255
    t.datetime "approved_at"
    t.integer  "approved_by_id", limit: 4
    t.integer  "country_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "headline_type",  limit: 4,     default: 1
  end

  add_index "headlines", ["approval"], name: "index_headlines_on_approval", using: :btree
  add_index "headlines", ["headline_type"], name: "index_headlines_on_headline_type", using: :btree
  add_index "headlines", ["published_on"], name: "index_headlines_on_published_on", using: :btree

  create_table "initiatives", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",     limit: 1,   default: true
  end

  create_table "integrity_measures", force: :cascade do |t|
    t.integer "local_network_id", limit: 4
    t.string  "title",            limit: 255
    t.string  "policy_type",      limit: 255
    t.text    "description",      limit: 65535
    t.date    "date"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "type",       limit: 255
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "issues", ["parent_id"], name: "index_issues_on_parent_id", using: :btree
  add_index "issues", ["type"], name: "index_issues_on_type", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "local_network_events", force: :cascade do |t|
    t.integer  "local_network_id",                 limit: 4
    t.string   "title",                            limit: 255
    t.text     "description",                      limit: 65535
    t.date     "date"
    t.string   "event_type",                       limit: 255
    t.integer  "num_participants",                 limit: 4
    t.integer  "gc_participant_percentage",        limit: 4
    t.boolean  "stakeholder_company",              limit: 1
    t.boolean  "stakeholder_sme",                  limit: 1
    t.boolean  "stakeholder_business_association", limit: 1
    t.boolean  "stakeholder_labour",               limit: 1
    t.boolean  "stakeholder_un_agency",            limit: 1
    t.boolean  "stakeholder_ngo",                  limit: 1
    t.boolean  "stakeholder_foundation",           limit: 1
    t.boolean  "stakeholder_academic",             limit: 1
    t.boolean  "stakeholder_government",           limit: 1
    t.boolean  "stakeholder_media",                limit: 1
    t.boolean  "stakeholder_others",               limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id",                       limit: 4
    t.string   "region",                           limit: 255
    t.text     "file_content",                     limit: 65535
  end

  create_table "local_network_events_principles", id: false, force: :cascade do |t|
    t.integer "local_network_event_id", limit: 4
    t.integer "principle_id",           limit: 4
  end

  add_index "local_network_events_principles", ["local_network_event_id"], name: "index_local_network_events_principles_on_local_network_event_id", using: :btree
  add_index "local_network_events_principles", ["principle_id"], name: "index_local_network_events_principles_on_principle_id", using: :btree

  create_table "local_networks", force: :cascade do |t|
    t.string   "name",                                                limit: 255
    t.string   "url",                                                 limit: 255
    t.string   "state",                                               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "sg_global_compact_launch_date"
    t.date     "sg_local_network_launch_date"
    t.boolean  "sg_annual_meeting_appointments",                      limit: 1
    t.integer  "sg_annual_meeting_appointments_file_id",              limit: 4
    t.boolean  "sg_selected_appointees_local_network_representative", limit: 1
    t.boolean  "sg_selected_appointees_steering_committee",           limit: 1
    t.boolean  "sg_selected_appointees_contact_point",                limit: 1
    t.boolean  "sg_established_as_a_legal_entity",                    limit: 1
    t.integer  "sg_established_as_a_legal_entity_file_id",            limit: 4
    t.boolean  "membership_subsidiaries",                             limit: 1
    t.integer  "membership_companies",                                limit: 4
    t.integer  "membership_sme",                                      limit: 4
    t.integer  "membership_micro_enterprise",                         limit: 4
    t.integer  "membership_business_organizations",                   limit: 4
    t.integer  "membership_csr_organizations",                        limit: 4
    t.integer  "membership_labour_organizations",                     limit: 4
    t.integer  "membership_civil_societies",                          limit: 4
    t.integer  "membership_academic_institutions",                    limit: 4
    t.integer  "membership_government",                               limit: 4
    t.integer  "membership_other",                                    limit: 4
    t.boolean  "fees_participant",                                    limit: 1
    t.integer  "fees_amount_company",                                 limit: 4
    t.integer  "fees_amount_sme",                                     limit: 4
    t.integer  "fees_amount_other_organization",                      limit: 4
    t.integer  "fees_amount_participant",                             limit: 4
    t.integer  "fees_amount_voluntary_private",                       limit: 4
    t.integer  "fees_amount_voluntary_public",                        limit: 4
    t.boolean  "stakeholder_company",                                 limit: 1
    t.boolean  "stakeholder_sme",                                     limit: 1
    t.boolean  "stakeholder_business_association",                    limit: 1
    t.boolean  "stakeholder_labour",                                  limit: 1
    t.boolean  "stakeholder_un_agency",                               limit: 1
    t.boolean  "stakeholder_ngo",                                     limit: 1
    t.boolean  "stakeholder_foundation",                              limit: 1
    t.boolean  "stakeholder_academic",                                limit: 1
    t.boolean  "stakeholder_government",                              limit: 1
    t.string   "twitter",                                             limit: 255
    t.string   "facebook",                                            limit: 255
    t.string   "linkedin",                                            limit: 255
    t.string   "funding_model",                                       limit: 255
    t.text     "description",                                         limit: 65535
    t.string   "image_file_name",                                     limit: 255
    t.string   "image_content_type",                                  limit: 255
    t.integer  "image_file_size",                                     limit: 4
    t.datetime "image_updated_at"
  end

  create_table "logo_comments", force: :cascade do |t|
    t.date     "added_on"
    t.integer  "old_id",                  limit: 4
    t.integer  "logo_request_id",         limit: 4
    t.integer  "contact_id",              limit: 4
    t.text     "body",                    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size",    limit: 4
    t.datetime "attachment_updated_at"
  end

  create_table "logo_files", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "description",          limit: 255
    t.integer  "old_id",               limit: 4
    t.string   "thumbnail",            limit: 255
    t.string   "file",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_file_name",        limit: 255
    t.string   "zip_content_type",     limit: 255
    t.integer  "zip_file_size",        limit: 4
    t.datetime "zip_updated_at"
    t.string   "preview_file_name",    limit: 255
    t.string   "preview_content_type", limit: 255
    t.integer  "preview_file_size",    limit: 4
    t.datetime "preview_updated_at"
  end

  create_table "logo_files_logo_requests", id: false, force: :cascade do |t|
    t.integer "logo_file_id",    limit: 4
    t.integer "logo_request_id", limit: 4
  end

  create_table "logo_publications", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "old_id",        limit: 4
    t.integer  "parent_id",     limit: 4
    t.integer  "display_order", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logo_requests", force: :cascade do |t|
    t.integer  "old_id",          limit: 4
    t.integer  "publication_id",  limit: 4
    t.integer  "organization_id", limit: 4
    t.integer  "contact_id",      limit: 4
    t.integer  "reviewer_id",     limit: 4
    t.boolean  "replied_to",      limit: 1
    t.string   "purpose",         limit: 255
    t.boolean  "accepted",        limit: 1
    t.date     "accepted_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",           limit: 255
    t.date     "approved_on"
  end

  create_table "meetings", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4
    t.string   "meeting_type",     limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mous", force: :cascade do |t|
    t.integer  "local_network_id", limit: 4
    t.date     "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mou_type",         limit: 255
  end

  create_table "non_business_organization_registrations", force: :cascade do |t|
    t.date    "date"
    t.string  "place",             limit: 255
    t.string  "authority",         limit: 255
    t.string  "number",            limit: 255
    t.text    "mission_statement", limit: 65535
    t.integer "organization_id",   limit: 4
  end

  add_index "non_business_organization_registrations", ["organization_id"], name: "index_non_business_organization_registrations_on_organization_id", using: :btree

  create_table "organization_types", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "type_property", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.integer  "old_id",                         limit: 4
    t.string   "name",                           limit: 255
    t.integer  "organization_type_id",           limit: 4
    t.integer  "sector_id",                      limit: 4
    t.boolean  "participant",                    limit: 1
    t.integer  "employees",                      limit: 4
    t.string   "url",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "joined_on"
    t.date     "delisted_on"
    t.boolean  "active",                         limit: 1
    t.integer  "country_id",                     limit: 4
    t.string   "stock_symbol",                   limit: 255
    t.integer  "removal_reason_id",              limit: 4
    t.integer  "last_modified_by_id",            limit: 4
    t.string   "state",                          limit: 255
    t.integer  "exchange_id",                    limit: 4
    t.integer  "listing_status_id",              limit: 4
    t.boolean  "is_ft_500",                      limit: 1
    t.date     "cop_due_on"
    t.date     "inactive_on"
    t.string   "commitment_letter_file_name",    limit: 255
    t.string   "commitment_letter_content_type", limit: 255
    t.integer  "commitment_letter_file_size",    limit: 4
    t.datetime "commitment_letter_updated_at"
    t.integer  "pledge_amount",                  limit: 4
    t.string   "cop_state",                      limit: 255
    t.boolean  "replied_to",                     limit: 1
    t.integer  "reviewer_id",                    limit: 4
    t.string   "bhr_url",                        limit: 255
    t.date     "rejected_on"
    t.date     "network_review_on"
    t.integer  "revenue",                        limit: 4
    t.date     "rejoined_on"
    t.date     "non_comm_dialogue_on"
    t.string   "review_reason",                  limit: 255
    t.integer  "participant_manager_id",         limit: 4
    t.boolean  "is_local_network_member",        limit: 1
    t.boolean  "is_landmine",                    limit: 1
    t.boolean  "is_tobacco",                     limit: 1
    t.string   "no_pledge_reason",               limit: 255
    t.string   "isin",                           limit: 255
  end

  add_index "organizations", ["country_id"], name: "index_organizations_on_country_id", using: :btree
  add_index "organizations", ["participant", "id"], name: "index_organizations_on_participant_and_id", using: :btree
  add_index "organizations", ["participant"], name: "index_organizations_on_participant", using: :btree
  add_index "organizations", ["participant_manager_id"], name: "index_organizations_on_participant_manager_id", using: :btree

  create_table "page_groups", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.boolean  "display_in_navigation", limit: 1
    t.string   "html_code",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position",              limit: 4
    t.string   "path_stub",             limit: 255
  end

  create_table "pages", force: :cascade do |t|
    t.string   "path",                  limit: 255
    t.string   "title",                 limit: 255
    t.string   "html_code",             limit: 255
    t.text     "content",               limit: 65535
    t.integer  "parent_id",             limit: 4
    t.integer  "position",              limit: 4
    t.boolean  "display_in_navigation", limit: 1
    t.datetime "approved_at"
    t.integer  "approved_by_id",        limit: 4
    t.integer  "created_by_id",         limit: 4
    t.integer  "updated_by_id",         limit: 4
    t.boolean  "dynamic_content",       limit: 1
    t.integer  "version_number",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",              limit: 4
    t.string   "approval",              limit: 255
    t.boolean  "top_level",             limit: 1
    t.string   "change_path",           limit: 255
  end

  add_index "pages", ["approval"], name: "index_pages_on_approval", using: :btree
  add_index "pages", ["group_id"], name: "index_pages_on_group_id", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", using: :btree
  add_index "pages", ["version_number"], name: "index_pages_on_version_number", using: :btree

  create_table "principles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       limit: 255
    t.integer  "parent_id",  limit: 4
    t.string   "reference",  limit: 255
  end

  create_table "principles_resources", id: false, force: :cascade do |t|
    t.integer  "principle_id", limit: 4
    t.integer  "resource_id",  limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "redesign_containers", force: :cascade do |t|
    t.integer  "layout",                 limit: 4,                  null: false
    t.string   "slug",                   limit: 255, default: "/",  null: false
    t.integer  "parent_container_id",    limit: 4
    t.integer  "public_payload_id",      limit: 4
    t.integer  "draft_payload_id",       limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "path",                   limit: 255
    t.integer  "depth",                  limit: 4,   default: 0,    null: false
    t.string   "tree_path",              limit: 255, default: "",   null: false
    t.integer  "child_containers_count", limit: 4,   default: 0,    null: false
    t.integer  "content_type",           limit: 4,   default: 1,    null: false
    t.boolean  "has_draft",              limit: 1,   default: true
    t.integer  "sort_order",             limit: 4,   default: 0
    t.boolean  "visible",                limit: 1,   default: true
    t.boolean  "draggable",              limit: 1,   default: true
  end

  add_index "redesign_containers", ["content_type"], name: "index_redesign_containers_on_content_type", using: :btree
  add_index "redesign_containers", ["depth"], name: "index_redesign_containers_on_depth", using: :btree
  add_index "redesign_containers", ["parent_container_id", "slug"], name: "index_redesign_containers_on_parent_container_id_and_slug", unique: true, using: :btree
  add_index "redesign_containers", ["parent_container_id"], name: "index_redesign_containers_on_parent_container_id", using: :btree
  add_index "redesign_containers", ["path"], name: "index_redesign_containers_on_path", unique: true, using: :btree

  create_table "redesign_payloads", force: :cascade do |t|
    t.integer  "container_id",   limit: 4,     null: false
    t.text     "json_data",      limit: 65535, null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "created_by_id",  limit: 4
    t.integer  "updated_by_id",  limit: 4
    t.integer  "approved_by_id", limit: 4
    t.datetime "approved_at"
  end

  create_table "redesign_searchables", force: :cascade do |t|
    t.datetime "last_indexed_at"
    t.string   "url",             limit: 255
    t.string   "document_type",   limit: 255
    t.text     "title",           limit: 65535
    t.text     "content",         limit: 65535
    t.text     "meta",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redesign_searchables", ["document_type", "url"], name: "index_redesign_searchables_on_document_type_and_url", using: :btree
  add_index "redesign_searchables", ["url"], name: "index_redesign_searchables_on_url", using: :btree

  create_table "removal_reasons", force: :cascade do |t|
    t.string   "description", limit: 255
    t.integer  "old_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_statuses", force: :cascade do |t|
    t.integer  "status",        limit: 4,     default: 0, null: false
    t.string   "filename",      limit: 255
    t.string   "path",          limit: 255
    t.text     "error_message", limit: 65535
    t.string   "format",        limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  create_table "resource_links", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "title",       limit: 255
    t.string   "link_type",   limit: 255
    t.integer  "resource_id", limit: 4
    t.integer  "language_id", limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "views",       limit: 4,   default: 0
  end

  create_table "resources", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.text     "description",        limit: 65535
    t.date     "year"
    t.string   "isbn",               limit: 255
    t.string   "approval",           limit: 255
    t.datetime "approved_at"
    t.integer  "approved_by_id",     limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "views",              limit: 4,     default: 0
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "content_type",       limit: 4
  end

  add_index "resources", ["content_type"], name: "index_resources_on_content_type", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "old_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id", limit: 4
    t.string   "description",   limit: 255
    t.integer  "position",      limit: 4
  end

  create_table "searchables", force: :cascade do |t|
    t.string   "title",             limit: 255
    t.text     "content",           limit: 65535
    t.string   "url",               limit: 255
    t.string   "document_type",     limit: 255
    t.datetime "last_indexed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "delta",             limit: 1,     default: true, null: false
    t.datetime "object_created_at"
    t.datetime "object_updated_at"
  end

  add_index "searchables", ["id", "delta"], name: "index_searchables_on_id_and_delta", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id",     limit: 4
    t.string   "icb_number", limit: 255
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "signings", force: :cascade do |t|
    t.integer  "old_id",          limit: 4
    t.integer  "initiative_id",   limit: 4
    t.integer  "organization_id", limit: 4
    t.date     "added_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "website_url", limit: 255
    t.string   "logo_url",    limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "author_id",                    limit: 4
    t.integer  "principle_id",                 limit: 4
    t.string   "principle_type",               limit: 255
    t.integer  "country_id",                   limit: 4
    t.integer  "initiative_id",                limit: 4
    t.integer  "language_id",                  limit: 4
    t.integer  "sector_id",                    limit: 4
    t.integer  "communication_on_progress_id", limit: 4
    t.integer  "event_id",                     limit: 4
    t.integer  "headline_id",                  limit: 4
    t.integer  "organization_id",              limit: 4
    t.integer  "resource_id",                  limit: 4
    t.integer  "redesign_container_id",        limit: 4
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "topic_id",                     limit: 4
    t.integer  "issue_id",                     limit: 4
    t.integer  "case_example_id",              limit: 4
  end

  add_index "taggings", ["author_id"], name: "index_taggings_on_author_id", using: :btree
  add_index "taggings", ["case_example_id"], name: "index_taggings_on_case_example_id", using: :btree
  add_index "taggings", ["communication_on_progress_id"], name: "index_taggings_on_communication_on_progress_id", using: :btree
  add_index "taggings", ["country_id"], name: "index_taggings_on_country_id", using: :btree
  add_index "taggings", ["event_id"], name: "index_taggings_on_event_id", using: :btree
  add_index "taggings", ["headline_id"], name: "index_taggings_on_headline_id", using: :btree
  add_index "taggings", ["initiative_id"], name: "index_taggings_on_initiative_id", using: :btree
  add_index "taggings", ["issue_id"], name: "index_taggings_on_issue_id", using: :btree
  add_index "taggings", ["language_id"], name: "index_taggings_on_language_id", using: :btree
  add_index "taggings", ["organization_id"], name: "index_taggings_on_organization_id", using: :btree
  add_index "taggings", ["principle_id"], name: "index_taggings_on_principle_id", using: :btree
  add_index "taggings", ["principle_type"], name: "index_taggings_on_principle_type", using: :btree
  add_index "taggings", ["redesign_container_id"], name: "index_taggings_on_redesign_container_id", using: :btree
  add_index "taggings", ["resource_id"], name: "index_taggings_on_resource_id", using: :btree
  add_index "taggings", ["sector_id"], name: "index_taggings_on_sector_id", using: :btree
  add_index "taggings", ["topic_id"], name: "index_taggings_on_topic_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "parent_id",  limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "topics", ["parent_id"], name: "index_topics_on_parent_id", using: :btree

  create_table "uploaded_files", force: :cascade do |t|
    t.integer  "attachable_id",                  limit: 4
    t.string   "attachable_type",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",           limit: 255
    t.integer  "attachment_file_size",           limit: 4
    t.string   "attachment_content_type",        limit: 255
    t.datetime "attachment_updated_at"
    t.string   "attachment_unmodified_filename", limit: 255
    t.string   "attachable_key",                 limit: 255
  end

  create_table "uploaded_images", force: :cascade do |t|
    t.string   "url",            limit: 255,                   null: false
    t.string   "filename",       limit: 255
    t.string   "mime",           limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.text     "licensing_data", limit: 65535
    t.boolean  "has_licensing",  limit: 1,     default: false
  end

  add_foreign_key "event_sponsors", "events"
  add_foreign_key "event_sponsors", "sponsors"
  add_foreign_key "events", "contacts"
  add_foreign_key "issues", "issues", column: "parent_id"
  add_foreign_key "taggings", "authors"
  add_foreign_key "taggings", "case_examples"
  add_foreign_key "taggings", "communication_on_progresses"
  add_foreign_key "taggings", "countries"
  add_foreign_key "taggings", "events"
  add_foreign_key "taggings", "headlines"
  add_foreign_key "taggings", "initiatives"
  add_foreign_key "taggings", "issues"
  add_foreign_key "taggings", "languages"
  add_foreign_key "taggings", "organizations"
  add_foreign_key "taggings", "principles"
  add_foreign_key "taggings", "redesign_containers"
  add_foreign_key "taggings", "resources"
  add_foreign_key "taggings", "sectors"
  add_foreign_key "taggings", "topics"
  add_foreign_key "topics", "topics", column: "parent_id"
end
