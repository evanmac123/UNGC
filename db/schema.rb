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

ActiveRecord::Schema.define(version: 20181213174943) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "citext"
  enable_extension "unaccent"

  create_table "academy_courses", force: :cascade do |t|
    t.string   "code"
    t.string   "name"
    t.string   "course_type"
    t.datetime "deleted_at"
    t.text     "description"
    t.string   "language"
    t.integer  "revision",    limit: 8
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "academy_courses", ["code"], name: "index_academy_courses_on_code", using: :btree

  create_table "academy_enrollments", force: :cascade do |t|
    t.integer  "contact_id"
    t.integer  "academy_course_id"
    t.datetime "completed_at"
    t.decimal  "completion_percentage",           precision: 14, scale: 4
    t.string   "event_id"
    t.datetime "first_access"
    t.datetime "last_access"
    t.decimal  "max_score",                       precision: 14, scale: 4
    t.string   "path_completion"
    t.string   "product_id"
    t.decimal  "score",                           precision: 14, scale: 4
    t.string   "so_id"
    t.string   "status"
    t.string   "task_id"
    t.integer  "time_in_course",        limit: 8
    t.string   "timezone"
    t.datetime "unenrolled_at"
    t.string   "user_id"
    t.string   "user_type"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "academy_enrollments", ["academy_course_id"], name: "index_academy_enrollments_on_academy_course_id", using: :btree
  add_index "academy_enrollments", ["contact_id"], name: "index_academy_enrollments_on_contact_id", using: :btree

  create_table "action_platform_orders", force: :cascade do |t|
    t.integer  "organization_id",                                  null: false
    t.integer  "financial_contact_id",                             null: false
    t.integer  "status",                           default: 0,     null: false
    t.integer  "price_cents",          limit: 8,   default: 0,     null: false
    t.string   "price_currency",       limit: 255, default: "USD", null: false
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
  end

  add_index "action_platform_orders", ["financial_contact_id"], name: "index_action_platform_orders_on_financial_contact_id", using: :btree

  create_table "action_platform_platforms", force: :cascade do |t|
    t.string   "name",              limit: 255,                  null: false
    t.string   "description",       limit: 5000,                 null: false
    t.date     "default_starts_at"
    t.date     "default_ends_at"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "slug",              limit: 32,                   null: false
    t.boolean  "discontinued",                   default: false, null: false
  end

  create_table "action_platform_subscriptions", force: :cascade do |t|
    t.integer  "contact_id",                                     null: false
    t.integer  "platform_id",                                    null: false
    t.integer  "order_id",                                       null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "organization_id",                                null: false
    t.integer  "status"
    t.date     "starts_on"
    t.date     "expires_on"
    t.string   "state",           limit: 20, default: "pending", null: false
  end

  add_index "action_platform_subscriptions", ["contact_id"], name: "index_action_platform_subscriptions_on_contact_id", using: :btree
  add_index "action_platform_subscriptions", ["order_id"], name: "index_action_platform_subscriptions_on_order_id", using: :btree
  add_index "action_platform_subscriptions", ["organization_id"], name: "index_action_platform_subscriptions_on_organization_id", using: :btree
  add_index "action_platform_subscriptions", ["platform_id"], name: "index_action_platform_subscriptions_on_platform_id", using: :btree

  create_table "announcements", force: :cascade do |t|
    t.integer  "local_network_id"
    t.integer  "principle_id"
    t.string   "title",            limit: 255
    t.string   "description",      limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "annual_reports", force: :cascade do |t|
    t.integer  "local_network_id"
    t.date     "year"
    t.boolean  "future_plans"
    t.boolean  "activities"
    t.boolean  "financials"
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
    t.integer  "author_id"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "awards", force: :cascade do |t|
    t.integer  "local_network_id"
    t.string   "title",            limit: 255
    t.text     "description"
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
    t.integer  "initiative_id"
    t.boolean  "is_deleted",                default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.boolean  "is_private",                default: false
  end

  add_index "campaigns", ["campaign_id"], name: "index_campaigns_on_campaign_id", unique: true, using: :btree
  add_index "campaigns", ["initiative_id"], name: "index_campaigns_on_initiative_id", using: :btree

  create_table "case_examples", force: :cascade do |t|
    t.string   "company",           limit: 255
    t.integer  "country_id"
    t.boolean  "is_participant"
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "case_examples", ["country_id"], name: "index_case_examples_on_country_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "body"
    t.integer  "commentable_id"
    t.string   "commentable_type",        limit: 255
    t.integer  "contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id", using: :btree
  add_index "comments", ["commentable_type"], name: "index_comments_on_commentable_type", using: :btree
  add_index "comments", ["contact_id"], name: "index_comments_on_contact_id", using: :btree

  create_table "communication_on_progresses", force: :cascade do |t|
    t.integer  "organization_id"
    t.string   "title",                               limit: 255
    t.string   "contact_info",                        limit: 255
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
    t.string   "state",                               limit: 255
    t.boolean  "include_continued_support_statement"
    t.string   "format",                              limit: 255
    t.boolean  "references_human_rights"
    t.boolean  "references_labour"
    t.boolean  "references_environment"
    t.boolean  "references_anti_corruption"
    t.boolean  "meets_advanced_criteria"
    t.boolean  "additional_questions"
    t.date     "starts_on"
    t.date     "ends_on"
    t.string   "method_shared",                       limit: 255
    t.string   "differentiation",                     limit: 255
    t.boolean  "references_business_peace"
    t.boolean  "references_water_mandate"
    t.string   "cop_type",                            limit: 255
    t.date     "published_on"
    t.integer  "submission_status",                               default: 0,                         null: false
    t.boolean  "endorses_ten_principles"
    t.boolean  "covers_issue_areas"
    t.boolean  "measures_outcomes"
    t.string   "type",                                limit: 255, default: "CommunicationOnProgress", null: false
  end

  add_index "communication_on_progresses", ["created_at"], name: "index_communication_on_progresses_on_created_at", using: :btree
  add_index "communication_on_progresses", ["differentiation"], name: "index_communication_on_progresses_on_differentiation", using: :btree
  add_index "communication_on_progresses", ["organization_id"], name: "index_communication_on_progresses_on_organization_id", using: :btree
  add_index "communication_on_progresses", ["state"], name: "index_communication_on_progresses_on_state", using: :btree
  add_index "communication_on_progresses", ["submission_status"], name: "index_communication_on_progresses_on_submission_status", using: :btree

  create_table "communication_on_progresses_countries", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id"
    t.integer "country_id"
  end

  create_table "communication_on_progresses_languages", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id"
    t.integer "language_id"
  end

  create_table "communication_on_progresses_principles", id: false, force: :cascade do |t|
    t.integer "communication_on_progress_id"
    t.integer "principle_id"
  end

  create_table "communications", force: :cascade do |t|
    t.integer "local_network_id"
    t.string  "title",              limit: 255
    t.string  "communication_type", limit: 255
    t.date    "date"
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "old_id"
    t.string   "first_name",                limit: 255
    t.string   "middle_name",               limit: 255
    t.string   "last_name",                 limit: 255
    t.string   "prefix",                    limit: 255
    t.string   "job_title",                 limit: 255
    t.string   "email",                     limit: 255
    t.string   "phone",                     limit: 255
    t.string   "mobile",                    limit: 255
    t.string   "fax",                       limit: 255
    t.integer  "organization_id"
    t.string   "address",                   limit: 255
    t.string   "city",                      limit: 255
    t.string   "state",                     limit: 255
    t.string   "postal_code",               limit: 255
    t.integer  "country_id"
    t.string   "username",                  limit: 255
    t.string   "address_more",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "remember_token_expires_at"
    t.string   "remember_token",            limit: 255
    t.integer  "local_network_id"
    t.string   "old_encrypted_password",    limit: 255
    t.string   "reset_password_token",      limit: 255
    t.datetime "last_sign_in_at"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         default: 0
    t.datetime "current_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.boolean  "welcome_package"
    t.string   "image_file_name",           limit: 255
    t.string   "image_content_type",        limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "encrypted_password",        limit: 255
    t.datetime "last_password_changed_at"
    t.string   "time_zone",                 limit: 32,  default: "UTC", null: false
    t.boolean  "full_time"
    t.string   "employer",                  limit: 200
  end

  add_index "contacts", ["organization_id"], name: "index_contacts_on_organization_id", using: :btree

  create_table "contacts_roles", id: false, force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "role_id",    null: false
  end

  add_index "contacts_roles", ["contact_id", "role_id"], name: "contacts_roles_idx_pk", unique: true, using: :btree
  add_index "contacts_roles", ["role_id"], name: "index_contacts_roles_on_role_id", using: :btree

  create_table "containers", force: :cascade do |t|
    t.integer  "layout",                                            null: false
    t.string   "slug",                   limit: 255, default: "/",  null: false
    t.integer  "parent_container_id"
    t.integer  "public_payload_id"
    t.integer  "draft_payload_id"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "path",                   limit: 255
    t.integer  "depth",                              default: 0,    null: false
    t.string   "tree_path",              limit: 255, default: "",   null: false
    t.integer  "child_containers_count",             default: 0,    null: false
    t.integer  "content_type",                       default: 1,    null: false
    t.boolean  "has_draft",                          default: true
    t.integer  "sort_order",                         default: 0
    t.boolean  "visible",                            default: true
    t.boolean  "draggable",                          default: true
  end

  add_index "containers", ["content_type"], name: "index_containers_on_content_type", using: :btree
  add_index "containers", ["depth"], name: "index_containers_on_depth", using: :btree
  add_index "containers", ["parent_container_id", "slug"], name: "index_containers_on_parent_container_id_and_slug", unique: true, using: :btree
  add_index "containers", ["parent_container_id"], name: "index_containers_on_parent_container_id", using: :btree
  add_index "containers", ["path"], name: "index_containers_on_path", unique: true, using: :btree

  create_table "contribution_descriptions", force: :cascade do |t|
    t.integer  "local_network_id", null: false
    t.text     "pledge"
    t.text     "pledge_continued"
    t.text     "payment"
    t.text     "contact"
    t.text     "additional"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "contribution_descriptions", ["local_network_id"], name: "index_contribution_descriptions_on_local_network_id", using: :btree

  create_table "contribution_levels", force: :cascade do |t|
    t.integer  "contribution_levels_info_id",             null: false
    t.string   "description",                 limit: 255, null: false
    t.string   "amount",                      limit: 255, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "order"
  end

  add_index "contribution_levels", ["contribution_levels_info_id"], name: "index_contribution_levels_on_contribution_levels_info_id", using: :btree
  add_index "contribution_levels", ["order"], name: "index_contribution_levels_on_order", using: :btree

  create_table "contribution_levels_infos", force: :cascade do |t|
    t.integer  "local_network_id"
    t.string   "level_description",  limit: 255
    t.string   "amount_description", limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "contribution_levels_infos", ["local_network_id"], name: "index_contribution_levels_infos_on_local_network_id", using: :btree

  create_table "contributions", force: :cascade do |t|
    t.string   "contribution_id",    limit: 255,                                          null: false
    t.string   "invoice_code",       limit: 255
    t.decimal  "raw_amount",                     precision: 10, scale: 2
    t.integer  "recognition_amount"
    t.date     "date",                                                                    null: false
    t.string   "stage",              limit: 255,                                          null: false
    t.string   "payment_type",       limit: 255
    t.integer  "organization_id",                                                         null: false
    t.string   "campaign_id",        limit: 255
    t.boolean  "is_deleted",                                              default: false, null: false
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  add_index "contributions", ["campaign_id"], name: "index_contributions_on_campaign_id", using: :btree
  add_index "contributions", ["contribution_id"], name: "index_contributions_on_contribution_id", unique: true, using: :btree
  add_index "contributions", ["organization_id"], name: "index_contributions_on_organization_id", using: :btree

  create_table "cop_answers", force: :cascade do |t|
    t.integer  "cop_id"
    t.integer  "cop_attribute_id"
    t.boolean  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text",             null: false
  end

  add_index "cop_answers", ["cop_attribute_id"], name: "index_cop_answers_on_cop_attribute_id", using: :btree
  add_index "cop_answers", ["cop_id"], name: "index_cop_answers_on_cop_id", using: :btree
  add_index "cop_answers", ["value"], name: "index_cop_answers_on_value", using: :btree

  create_table "cop_attributes", force: :cascade do |t|
    t.integer  "cop_question_id"
    t.string   "text",            limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hint"
    t.boolean  "open",                        default: false
  end

  add_index "cop_attributes", ["cop_question_id", "position"], name: "index_cop_attributes_on_cop_question_id_and_position", using: :btree
  add_index "cop_attributes", ["text"], name: "index_cop_attributes_on_text", using: :btree

  create_table "cop_files", force: :cascade do |t|
    t.integer  "cop_id"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type",         limit: 255
    t.integer  "language_id"
  end

  create_table "cop_links", force: :cascade do |t|
    t.integer  "cop_id"
    t.string   "url",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_type", limit: 255
    t.integer  "language_id"
  end

  create_table "cop_log_entries", force: :cascade do |t|
    t.string   "event",           limit: 255
    t.string   "cop_type",        limit: 255
    t.string   "status",          limit: 255
    t.text     "error_message"
    t.integer  "contact_id"
    t.integer  "organization_id"
    t.text     "params"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "cop_log_entries", ["contact_id"], name: "index_cop_log_entries_on_contact_id", using: :btree
  add_index "cop_log_entries", ["organization_id"], name: "index_cop_log_entries_on_organization_id", using: :btree

  create_table "cop_questions", force: :cascade do |t|
    t.integer  "principle_area_id"
    t.string   "text",              limit: 255
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id"
    t.string   "grouping",          limit: 255
    t.string   "implementation",    limit: 255
    t.integer  "year"
  end

  add_index "cop_questions", ["principle_area_id", "position"], name: "index_cop_questions_on_principle_area_id_and_position", using: :btree

  create_table "cop_scores", force: :cascade do |t|
    t.string   "description", limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: :cascade do |t|
    t.string   "code",                   limit: 255
    t.string   "name",                   limit: 255
    t.string   "region",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "manager_id"
    t.integer  "local_network_id"
    t.integer  "participant_manager_id"
    t.integer  "regional_center_id"
    t.boolean  "oecd",                               default: false
  end

  add_index "countries", ["participant_manager_id"], name: "index_countries_on_participant_manager_id", using: :btree
  add_index "countries", ["region"], name: "index_countries_on_region", using: :btree

  create_table "crm_owners", force: :cascade do |t|
    t.integer  "contact_id",             null: false
    t.string   "crm_id",     limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "crm_owners", ["contact_id"], name: "index_crm_owners_on_contact_id", unique: true, using: :btree

  create_table "donations", force: :cascade do |t|
    t.integer  "amount_cents",     limit: 8,   default: 0,     null: false
    t.string   "amount_currency",  limit: 255, default: "USD", null: false
    t.string   "first_name",       limit: 255,                 null: false
    t.string   "last_name",        limit: 255,                 null: false
    t.string   "company_name",     limit: 255,                 null: false
    t.string   "address",          limit: 255,                 null: false
    t.string   "address_more",     limit: 255
    t.string   "city",             limit: 255,                 null: false
    t.string   "state",            limit: 255,                 null: false
    t.string   "postal_code",      limit: 255,                 null: false
    t.string   "country_name",     limit: 255,                 null: false
    t.string   "email_address",    limit: 255,                 null: false
    t.integer  "contact_id"
    t.integer  "organization_id"
    t.string   "reference",        limit: 255,                 null: false
    t.string   "response_id",      limit: 255
    t.text     "full_response"
    t.integer  "status"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "invoice_number",   limit: 255
    t.string   "credit_card_type", limit: 255
  end

  create_table "due_diligence_reviews", force: :cascade do |t|
    t.integer  "organization_id"
    t.integer  "requester_id"
    t.string   "state",                              limit: 255,  null: false
    t.integer  "level_of_engagement"
    t.string   "world_check_allegations",            limit: 2000
    t.boolean  "included_in_global_marketplace"
    t.boolean  "subject_to_sanctions"
    t.boolean  "excluded_by_norwegian_pension_fund"
    t.boolean  "involved_in_landmines"
    t.boolean  "involved_in_tobacco"
    t.integer  "esg_score"
    t.integer  "highest_controversy_level"
    t.integer  "rep_risk_peak"
    t.integer  "rep_risk_current"
    t.integer  "rep_risk_severity_of_news"
    t.string   "local_network_input",                limit: 2000
    t.boolean  "requires_local_network_input"
    t.text     "analysis_comments"
    t.text     "additional_research"
    t.string   "integrity_explanation",              limit: 1000
    t.string   "engagement_rationale",               limit: 2000
    t.string   "approving_chief",                    limit: 100
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.text     "additional_information"
    t.integer  "reason_for_decline"
    t.boolean  "subject_to_dialog_facilitation"
    t.integer  "with_reservation"
    t.integer  "event_id"
    t.string   "individual_subject",                 limit: 100
  end

  add_index "due_diligence_reviews", ["event_id"], name: "index_due_diligence_reviews_on_event_id", using: :btree
  add_index "due_diligence_reviews", ["organization_id"], name: "index_due_diligence_reviews_on_organization_id", using: :btree
  add_index "due_diligence_reviews", ["requester_id"], name: "index_due_diligence_reviews_on_requester_id", using: :btree

  create_table "event_sponsors", force: :cascade do |t|
    t.integer "event_id"
    t.integer "sponsor_id"
  end

  add_index "event_sponsors", ["event_id"], name: "index_event_sponsors_on_event_id", using: :btree
  add_index "event_sponsors", ["sponsor_id"], name: "index_event_sponsors_on_sponsor_id", using: :btree

  create_table "event_store_events", force: :cascade do |t|
    t.string   "stream",     limit: 255, null: false
    t.string   "event_type", limit: 255, null: false
    t.string   "event_id",   limit: 255, null: false
    t.text     "metadata"
    t.text     "data",                   null: false
    t.datetime "created_at",             null: false
  end

  add_index "event_store_events", ["created_at"], name: "index_event_store_events_on_created_at", using: :btree
  add_index "event_store_events", ["event_id"], name: "index_event_store_events_on_event_id", unique: true, using: :btree
  add_index "event_store_events", ["event_type"], name: "index_event_store_events_on_event_type", using: :btree
  add_index "event_store_events", ["stream"], name: "index_event_store_events_on_stream", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "title",                        limit: 255
    t.text     "description"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.text     "location"
    t.integer  "country_id"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.string   "approval",                     limit: 255
    t.boolean  "is_all_day"
    t.boolean  "is_online"
    t.boolean  "is_invitation_only"
    t.integer  "priority",                                 default: 1
    t.integer  "contact_id"
    t.string   "thumbnail_image_file_name",    limit: 255
    t.string   "thumbnail_image_content_type", limit: 255
    t.integer  "thumbnail_image_file_size"
    t.datetime "thumbnail_image_updated_at"
    t.string   "banner_image_file_name",       limit: 255
    t.string   "banner_image_content_type",    limit: 255
    t.integer  "banner_image_file_size"
    t.datetime "banner_image_updated_at"
    t.string   "call_to_action_1_label",       limit: 255
    t.string   "call_to_action_1_url",         limit: 255
    t.string   "call_to_action_2_label",       limit: 255
    t.string   "call_to_action_2_url",         limit: 255
    t.text     "programme_description"
    t.text     "media_description"
    t.string   "tab_1_title",                  limit: 255
    t.text     "tab_1_description"
    t.string   "tab_2_title",                  limit: 255
    t.text     "tab_2_description"
    t.string   "tab_3_title",                  limit: 255
    t.text     "tab_3_description"
    t.text     "sponsors_description"
    t.string   "tab_4_title",                  limit: 255
    t.text     "tab_4_description"
    t.string   "tab_5_title",                  limit: 255
    t.text     "tab_5_description"
    t.boolean  "is_academy"
  end

  add_index "events", ["contact_id"], name: "index_events_on_contact_id", using: :btree

  create_table "events_principles", id: false, force: :cascade do |t|
    t.integer "event_id"
    t.integer "principle_area_id"
  end

  create_table "exchanges", force: :cascade do |t|
    t.string   "code",           limit: 255
    t.string   "name",           limit: 255
    t.string   "secondary_code", limit: 255
    t.string   "terciary_code",  limit: 255
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "headlines", force: :cascade do |t|
    t.string   "title",                limit: 255
    t.text     "description"
    t.string   "location",             limit: 255
    t.date     "published_on"
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.string   "approval",             limit: 255
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "headline_type",                    default: 1
    t.integer  "contact_id"
    t.string   "call_to_action_label", limit: 255
    t.string   "call_to_action_url",   limit: 255
  end

  add_index "headlines", ["approval"], name: "index_headlines_on_approval", using: :btree
  add_index "headlines", ["contact_id"], name: "index_headlines_on_contact_id", using: :btree
  add_index "headlines", ["headline_type"], name: "index_headlines_on_headline_type", using: :btree
  add_index "headlines", ["published_on"], name: "index_headlines_on_published_on", using: :btree

  create_table "igloo_users", force: :cascade do |t|
    t.integer  "contact_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "igloo_users", ["contact_id"], name: "index_igloo_users_on_contact_id", using: :btree

  create_table "initiatives", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                   default: true
    t.string   "sitemap_path", limit: 255
  end

  add_index "initiatives", ["name"], name: "unique_index_initiatives_on_name", unique: true, using: :btree

  create_table "integrity_measures", force: :cascade do |t|
    t.integer "local_network_id"
    t.string  "title",            limit: 255
    t.string  "policy_type",      limit: 255
    t.text    "description"
    t.date    "date"
  end

  create_table "issues", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "type",       limit: 255
    t.integer  "parent_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "issues", ["parent_id"], name: "index_issues_on_parent_id", using: :btree
  add_index "issues", ["type"], name: "index_issues_on_type", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listing_statuses", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "local_network_events", force: :cascade do |t|
    t.integer  "local_network_id"
    t.string   "title",                            limit: 255
    t.text     "description"
    t.date     "date"
    t.string   "event_type",                       limit: 255
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
    t.string   "region",                           limit: 255
    t.text     "file_content"
  end

  create_table "local_network_events_principles", id: false, force: :cascade do |t|
    t.integer "local_network_event_id"
    t.integer "principle_id"
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
    t.string   "twitter",                                             limit: 255
    t.string   "facebook",                                            limit: 255
    t.string   "linkedin",                                            limit: 255
    t.string   "funding_model",                                       limit: 255
    t.text     "description"
    t.string   "image_file_name",                                     limit: 255
    t.string   "image_content_type",                                  limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "business_model"
    t.integer  "invoice_managed_by"
    t.integer  "invoice_options_available"
    t.string   "invoice_currency",                                    limit: 255
  end

  create_table "logo_comments", force: :cascade do |t|
    t.date     "added_on"
    t.integer  "old_id"
    t.integer  "logo_request_id"
    t.integer  "contact_id"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",    limit: 255
    t.string   "attachment_content_type", limit: 255
    t.integer  "attachment_file_size"
    t.datetime "attachment_updated_at"
  end

  create_table "logo_files", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "description",          limit: 255
    t.integer  "old_id"
    t.string   "thumbnail",            limit: 255
    t.string   "file",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip_file_name",        limit: 255
    t.string   "zip_content_type",     limit: 255
    t.integer  "zip_file_size"
    t.datetime "zip_updated_at"
    t.string   "preview_file_name",    limit: 255
    t.string   "preview_content_type", limit: 255
    t.integer  "preview_file_size"
    t.datetime "preview_updated_at"
  end

  create_table "logo_files_logo_requests", id: false, force: :cascade do |t|
    t.integer "logo_file_id"
    t.integer "logo_request_id"
  end

  create_table "logo_publications", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "old_id"
    t.integer  "parent_id"
    t.integer  "display_order"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "logo_requests", force: :cascade do |t|
    t.integer  "old_id"
    t.integer  "publication_id"
    t.integer  "organization_id"
    t.integer  "contact_id"
    t.integer  "reviewer_id"
    t.boolean  "replied_to"
    t.string   "purpose",         limit: 255
    t.boolean  "accepted"
    t.date     "accepted_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",           limit: 255
    t.date     "approved_on"
  end

  create_table "meetings", force: :cascade do |t|
    t.integer  "local_network_id"
    t.string   "meeting_type",     limit: 255
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mous", force: :cascade do |t|
    t.integer  "local_network_id"
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
    t.text    "mission_statement"
    t.integer "organization_id"
  end

  add_index "non_business_organization_registrations", ["organization_id"], name: "index_non_business_org_registrations_on_org_id", using: :btree

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id",             null: false
    t.integer  "application_id",                null: false
    t.string   "token",             limit: 255, null: false
    t.integer  "expires_in",                    null: false
    t.text     "redirect_uri",                  null: false
    t.datetime "created_at",                    null: false
    t.datetime "revoked_at"
    t.string   "scopes",            limit: 255
  end

  add_index "oauth_access_grants", ["application_id"], name: "fk_rails_b4b53e07b8", using: :btree
  add_index "oauth_access_grants", ["resource_owner_id"], name: "fk_rails_330c32d8d9", using: :btree
  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",                  limit: 255,              null: false
    t.string   "refresh_token",          limit: 255
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",                                      null: false
    t.string   "scopes",                 limit: 255
    t.string   "previous_refresh_token", limit: 255, default: "", null: false
  end

  add_index "oauth_access_tokens", ["application_id"], name: "fk_rails_732cb83ab7", using: :btree
  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",         limit: 255,              null: false
    t.string   "uid",          limit: 255,              null: false
    t.string   "secret",       limit: 255,              null: false
    t.text     "redirect_uri",                          null: false
    t.string   "scopes",       limit: 255, default: "", null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "organization_social_networks", force: :cascade do |t|
    t.integer  "organization_id",            null: false
    t.string   "network_code",    limit: 30, null: false
    t.string   "handle",          limit: 50, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "organization_social_networks", ["network_code", "handle"], name: "index_organization_social_networks_handles", unique: true, using: :btree
  add_index "organization_social_networks", ["organization_id", "network_code"], name: "organization_social_networks_pk", unique: true, using: :btree

  create_table "organization_types", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "type_property"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "organizations", force: :cascade do |t|
    t.integer  "old_id"
    t.string   "name",                           limit: 255
    t.integer  "organization_type_id"
    t.integer  "sector_id"
    t.boolean  "participant"
    t.integer  "employees"
    t.string   "url",                            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "joined_on"
    t.date     "delisted_on"
    t.boolean  "active"
    t.integer  "country_id"
    t.string   "stock_symbol",                   limit: 255
    t.integer  "removal_reason_id"
    t.integer  "last_modified_by_id"
    t.string   "state",                          limit: 255
    t.integer  "exchange_id"
    t.integer  "listing_status_id"
    t.boolean  "is_ft_500"
    t.date     "cop_due_on"
    t.date     "inactive_on"
    t.string   "commitment_letter_file_name",    limit: 255
    t.string   "commitment_letter_content_type", limit: 255
    t.integer  "commitment_letter_file_size"
    t.datetime "commitment_letter_updated_at"
    t.integer  "pledge_amount"
    t.string   "cop_state",                      limit: 255
    t.boolean  "replied_to"
    t.integer  "reviewer_id"
    t.string   "bhr_url",                        limit: 255
    t.date     "rejected_on"
    t.date     "network_review_on"
    t.integer  "revenue"
    t.date     "rejoined_on"
    t.date     "non_comm_dialogue_on"
    t.string   "review_reason",                  limit: 255
    t.integer  "participant_manager_id"
    t.boolean  "is_local_network_member"
    t.boolean  "is_landmine"
    t.boolean  "is_tobacco"
    t.string   "no_pledge_reason",               limit: 255
    t.string   "isin",                           limit: 255
    t.integer  "precise_revenue_cents",          limit: 8
    t.string   "precise_revenue_currency",       limit: 255,  default: "USD", null: false
    t.boolean  "is_biological_weapons"
    t.integer  "level_of_participation"
    t.date     "invoice_date"
    t.integer  "parent_company_id"
    t.string   "government_registry_url",        limit: 2000
    t.string   "video_embed",                    limit: 500
    t.boolean  "accepts_eula"
  end

  add_index "organizations", ["country_id"], name: "index_organizations_on_country_id", using: :btree
  add_index "organizations", ["listing_status_id"], name: "index_organizations_on_listing_status_id", using: :btree
  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree
  add_index "organizations", ["participant", "id"], name: "index_organizations_on_participant_and_id", using: :btree
  add_index "organizations", ["participant"], name: "index_organizations_on_participant", using: :btree
  add_index "organizations", ["participant_manager_id"], name: "index_organizations_on_participant_manager_id", using: :btree
  add_index "organizations", ["sector_id"], name: "index_organizations_on_sector_id", using: :btree

  create_table "page_groups", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.boolean  "display_in_navigation"
    t.string   "html_code",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.string   "path_stub",             limit: 255
  end

  create_table "pages", force: :cascade do |t|
    t.string   "path",                  limit: 255
    t.string   "title",                 limit: 255
    t.string   "html_code",             limit: 255
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
    t.string   "approval",              limit: 255
    t.boolean  "top_level"
    t.string   "change_path",           limit: 255
  end

  add_index "pages", ["approval"], name: "index_pages_on_approval", using: :btree
  add_index "pages", ["group_id"], name: "index_pages_on_group_id", using: :btree
  add_index "pages", ["parent_id"], name: "index_pages_on_parent_id", using: :btree
  add_index "pages", ["path"], name: "index_pages_on_path", using: :btree
  add_index "pages", ["version_number"], name: "index_pages_on_version_number", using: :btree

  create_table "payloads", force: :cascade do |t|
    t.integer  "container_id",   null: false
    t.text     "json_data",      null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "created_by_id"
    t.integer  "updated_by_id"
    t.integer  "approved_by_id"
    t.datetime "approved_at"
  end

  create_table "principles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",       limit: 255
    t.integer  "parent_id"
    t.string   "reference",  limit: 255
  end

  create_table "principles_resources", id: false, force: :cascade do |t|
    t.integer  "principle_id"
    t.integer  "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "removal_reasons", force: :cascade do |t|
    t.string   "description", limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "report_statuses", force: :cascade do |t|
    t.integer  "status",                    default: 0, null: false
    t.string   "filename",      limit: 255
    t.string   "path",          limit: 255
    t.text     "error_message"
    t.string   "format",        limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "reporting_reminder_email_statuses", force: :cascade do |t|
    t.integer  "organization_id",             null: false
    t.boolean  "success",                     null: false
    t.text     "message"
    t.string   "reporting_type",  limit: 255
    t.string   "email",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "resource_links", force: :cascade do |t|
    t.string   "url",         limit: 255
    t.string   "title",       limit: 255
    t.string   "link_type",   limit: 255
    t.integer  "resource_id"
    t.integer  "language_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "views",                   default: 0
  end

  create_table "resource_weights", force: :cascade do |t|
    t.integer  "resource_id"
    t.text     "full_text",                   null: false
    t.text     "full_text_raw",               null: false
    t.jsonb    "weights",        default: {}, null: false
    t.text     "resource_title",              null: false
    t.text     "resource_url",                null: false
    t.text     "resource_type",               null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "resource_weights", ["resource_id"], name: "index_resource_weights_on_resource_id", using: :btree
  add_index "resource_weights", ["weights"], name: "index_resource_weights_on_weights", using: :gin

  create_table "resources", force: :cascade do |t|
    t.string   "title",              limit: 255
    t.text     "description"
    t.date     "year"
    t.string   "isbn",               limit: 255
    t.string   "approval",           limit: 255
    t.datetime "approved_at"
    t.integer  "approved_by_id"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.integer  "views",                          default: 0
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "content_type"
  end

  add_index "resources", ["content_type"], name: "index_resources_on_content_type", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "old_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "initiative_id"
    t.string   "description",   limit: 255
    t.integer  "position"
  end

  create_table "salesforce_records", force: :cascade do |t|
    t.string   "record_id",  limit: 18,  null: false
    t.integer  "rails_id"
    t.string   "rails_type", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "salesforce_records", ["rails_type", "rails_id"], name: "salesforce_rails_type_idx", using: :btree
  add_index "salesforce_records", ["record_id"], name: "salesforce_record_id_uidx", unique: true, using: :btree

  create_table "sdg_pioneer_others", force: :cascade do |t|
    t.string   "submitter_name",            limit: 255
    t.string   "submitter_place_of_work",   limit: 255
    t.string   "submitter_email",           limit: 255
    t.string   "nominee_name",              limit: 255
    t.string   "nominee_email",             limit: 255
    t.string   "nominee_phone",             limit: 255
    t.string   "nominee_work_place",        limit: 255
    t.string   "organization_type",         limit: 255
    t.string   "submitter_job_title",       limit: 255
    t.string   "submitter_phone",           limit: 255
    t.boolean  "accepts_tou",                           default: false, null: false
    t.string   "nominee_title",             limit: 255
    t.text     "why_nominate"
    t.integer  "sdg_pioneer_role"
    t.datetime "emailed_at"
    t.boolean  "is_participant"
    t.string   "organization_name",         limit: 255
    t.boolean  "organization_name_matched"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sdg_pioneer_submissions", force: :cascade do |t|
    t.integer  "pioneer_type"
    t.text     "global_goals_activity"
    t.string   "matching_sdgs",             limit: 255
    t.string   "name",                      limit: 255
    t.string   "title",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "phone",                     limit: 255
    t.string   "organization_name",         limit: 255
    t.boolean  "organization_name_matched",             default: true,  null: false
    t.string   "country_name",              limit: 255
    t.text     "reason_for_being"
    t.boolean  "accepts_tou",                           default: false, null: false
    t.boolean  "is_participant"
    t.string   "website_url",               limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.text     "company_success"
    t.text     "innovative_sdgs"
    t.text     "ten_principles"
    t.text     "awareness_and_mobilize"
    t.boolean  "accepts_interview"
    t.boolean  "has_local_network"
    t.text     "local_network_question"
    t.integer  "organization_id"
  end

  add_index "sdg_pioneer_submissions", ["organization_id"], name: "index_sdg_pioneer_submissions_on_organization_id", using: :btree

  create_table "searchables", force: :cascade do |t|
    t.datetime "last_indexed_at"
    t.string   "url",             limit: 255
    t.string   "document_type",   limit: 255
    t.text     "title"
    t.text     "content"
    t.text     "meta"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searchables", ["document_type", "url"], name: "index_searchables_on_document_type_and_url", using: :btree
  add_index "searchables", ["url"], name: "index_searchables_on_url", using: :btree

  create_table "sectors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "old_id"
    t.string   "icb_number", limit: 255
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "preserved",              default: false, null: false
  end

  add_index "sectors", ["name"], name: "index_sectors_on_name", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "signings", force: :cascade do |t|
    t.integer  "old_id"
    t.integer  "initiative_id"
    t.integer  "organization_id"
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

  create_table "sustainable_development_goals", force: :cascade do |t|
    t.string   "name",        limit: 255, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "goal_number",             null: false
  end

  create_table "taggings", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "principle_id"
    t.string   "principle_type",                  limit: 255
    t.integer  "country_id"
    t.integer  "initiative_id"
    t.integer  "language_id"
    t.integer  "sector_id"
    t.integer  "communication_on_progress_id"
    t.integer  "event_id"
    t.integer  "headline_id"
    t.integer  "organization_id"
    t.integer  "resource_id"
    t.integer  "container_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "topic_id"
    t.integer  "issue_id"
    t.integer  "case_example_id"
    t.integer  "sustainable_development_goal_id"
    t.integer  "action_platform_id"
  end

  add_index "taggings", ["action_platform_id"], name: "index_taggings_on_action_platform_id", using: :btree
  add_index "taggings", ["author_id"], name: "index_taggings_on_author_id", using: :btree
  add_index "taggings", ["case_example_id"], name: "index_taggings_on_case_example_id", using: :btree
  add_index "taggings", ["communication_on_progress_id"], name: "index_taggings_on_communication_on_progress_id", using: :btree
  add_index "taggings", ["container_id"], name: "index_taggings_on_container_id", using: :btree
  add_index "taggings", ["country_id"], name: "index_taggings_on_country_id", using: :btree
  add_index "taggings", ["event_id"], name: "index_taggings_on_event_id", using: :btree
  add_index "taggings", ["headline_id"], name: "index_taggings_on_headline_id", using: :btree
  add_index "taggings", ["initiative_id"], name: "index_taggings_on_initiative_id", using: :btree
  add_index "taggings", ["issue_id"], name: "index_taggings_on_issue_id", using: :btree
  add_index "taggings", ["language_id"], name: "index_taggings_on_language_id", using: :btree
  add_index "taggings", ["organization_id"], name: "index_taggings_on_organization_id", using: :btree
  add_index "taggings", ["principle_id"], name: "index_taggings_on_principle_id", using: :btree
  add_index "taggings", ["principle_type"], name: "index_taggings_on_principle_type", using: :btree
  add_index "taggings", ["resource_id"], name: "index_taggings_on_resource_id", using: :btree
  add_index "taggings", ["sector_id"], name: "index_taggings_on_sector_id", using: :btree
  add_index "taggings", ["sustainable_development_goal_id"], name: "index_taggings_on_sustainable_development_goal_id", using: :btree
  add_index "taggings", ["topic_id"], name: "index_taggings_on_topic_id", using: :btree

  create_table "topics", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.integer  "parent_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "topics", ["parent_id"], name: "index_topics_on_parent_id", using: :btree

  create_table "uploaded_files", force: :cascade do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attachment_file_name",           limit: 255
    t.integer  "attachment_file_size"
    t.string   "attachment_content_type",        limit: 255
    t.datetime "attachment_updated_at"
    t.string   "attachment_unmodified_filename", limit: 255
    t.string   "attachable_key",                 limit: 255
  end

  create_table "uploaded_images", force: :cascade do |t|
    t.string   "url",            limit: 255,                 null: false
    t.string   "filename",       limit: 255
    t.string   "mime",           limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "licensing_data"
    t.boolean  "has_licensing",              default: false
  end

  add_foreign_key "academy_enrollments", "academy_courses"
  add_foreign_key "academy_enrollments", "contacts"
  add_foreign_key "action_platform_orders", "contacts", column: "financial_contact_id"
  add_foreign_key "action_platform_subscriptions", "action_platform_orders", column: "order_id"
  add_foreign_key "action_platform_subscriptions", "action_platform_platforms", column: "platform_id"
  add_foreign_key "action_platform_subscriptions", "contacts"
  add_foreign_key "action_platform_subscriptions", "organizations"
  add_foreign_key "contacts_roles", "contacts", on_delete: :cascade
  add_foreign_key "contacts_roles", "roles", on_delete: :cascade
  add_foreign_key "crm_owners", "contacts"
  add_foreign_key "due_diligence_reviews", "contacts", column: "requester_id"
  add_foreign_key "due_diligence_reviews", "organizations"
  add_foreign_key "event_sponsors", "events"
  add_foreign_key "event_sponsors", "sponsors"
  add_foreign_key "events", "contacts"
  add_foreign_key "headlines", "contacts"
  add_foreign_key "igloo_users", "contacts"
  add_foreign_key "issues", "issues", column: "parent_id"
  add_foreign_key "oauth_access_grants", "contacts", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "contacts", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "organization_social_networks", "organizations", on_delete: :cascade
  add_foreign_key "organizations", "listing_statuses", on_delete: :nullify
  add_foreign_key "resource_weights", "resources"
  add_foreign_key "sdg_pioneer_submissions", "organizations"
  add_foreign_key "taggings", "action_platform_platforms", column: "action_platform_id"
  add_foreign_key "taggings", "authors"
  add_foreign_key "taggings", "case_examples"
  add_foreign_key "taggings", "communication_on_progresses"
  add_foreign_key "taggings", "containers"
  add_foreign_key "taggings", "countries"
  add_foreign_key "taggings", "events"
  add_foreign_key "taggings", "headlines"
  add_foreign_key "taggings", "initiatives"
  add_foreign_key "taggings", "issues"
  add_foreign_key "taggings", "languages"
  add_foreign_key "taggings", "organizations"
  add_foreign_key "taggings", "principles"
  add_foreign_key "taggings", "resources"
  add_foreign_key "taggings", "sectors"
  add_foreign_key "taggings", "sustainable_development_goals"
  add_foreign_key "taggings", "topics"
  add_foreign_key "topics", "topics", column: "parent_id"
end
