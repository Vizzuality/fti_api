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

ActiveRecord::Schema.define(version: 20201104135131) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"
  enable_extension "address_standardizer"
  enable_extension "address_standardizer_data_us"
  enable_extension "citext"
  enable_extension "fuzzystrmatch"
  enable_extension "postgis_tiger_geocoder"
  enable_extension "postgis_topology"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_type"
    t.integer  "resource_id"
    t.string   "author_type"
    t.integer  "author_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "annex_documents", force: :cascade do |t|
    t.string   "documentable_type",          null: false
    t.integer  "documentable_id",            null: false
    t.integer  "operator_document_annex_id", null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["documentable_id"], name: "index_annex_documents_on_documentable_id", using: :btree
    t.index ["documentable_type"], name: "index_annex_documents_on_documentable_type", using: :btree
    t.index ["operator_document_annex_id"], name: "index_annex_documents_on_operator_document_annex_id", using: :btree
  end

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.datetime "expires_at"
    t.integer  "user_id"
    t.boolean  "is_active",    default: true
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.index ["access_token"], name: "index_api_keys_on_access_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_api_keys_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "category_type"
  end

  create_table "category_translations", force: :cascade do |t|
    t.integer  "category_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.index ["category_id"], name: "index_category_translations_on_category_id", using: :btree
    t.index ["locale"], name: "index_category_translations_on_locale", using: :btree
    t.index ["name", "category_id"], name: "index_category_translations_on_name_and_category_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body"
    t.integer  "user_id",          null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contributor_translations", force: :cascade do |t|
    t.integer  "contributor_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name",           null: false
    t.text     "description"
    t.index ["contributor_id"], name: "index_contributor_translations_on_contributor_id", using: :btree
    t.index ["locale"], name: "index_contributor_translations_on_locale", using: :btree
  end

  create_table "contributors", force: :cascade do |t|
    t.string   "website"
    t.string   "logo"
    t.integer  "priority"
    t.integer  "category"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "type",       default: "Partner"
    t.index ["type"], name: "index_contributors_on_type", using: :btree
  end

  create_table "countries", force: :cascade do |t|
    t.string   "iso"
    t.string   "region_iso"
    t.jsonb    "country_centroid"
    t.jsonb    "region_centroid"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "is_active",                  default: false, null: false
    t.float    "percentage_valid_documents"
    t.index ["is_active"], name: "index_countries_on_is_active", using: :btree
    t.index ["iso"], name: "index_countries_on_iso", using: :btree
  end

  create_table "countries_observers", id: false, force: :cascade do |t|
    t.integer "country_id",  null: false
    t.integer "observer_id", null: false
    t.index ["country_id", "observer_id"], name: "index_countries_observers_on_country_id_and_observer_id", using: :btree
    t.index ["country_id", "observer_id"], name: "index_unique_country_observer", unique: true, using: :btree
    t.index ["observer_id", "country_id"], name: "index_countries_observers_on_observer_id_and_country_id", using: :btree
  end

  create_table "country_link_translations", force: :cascade do |t|
    t.integer  "country_link_id", null: false
    t.string   "locale",          null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "name"
    t.text     "description"
    t.index ["country_link_id"], name: "index_country_link_translations_on_country_link_id", using: :btree
    t.index ["locale"], name: "index_country_link_translations_on_locale", using: :btree
  end

  create_table "country_links", force: :cascade do |t|
    t.string   "url"
    t.boolean  "active",     default: true
    t.integer  "position"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "country_id"
    t.index ["country_id"], name: "index_country_links_on_country_id", using: :btree
  end

  create_table "country_translations", force: :cascade do |t|
    t.integer  "country_id",  null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.string   "region_name"
    t.index ["country_id"], name: "index_country_translations_on_country_id", using: :btree
    t.index ["locale"], name: "index_country_translations_on_locale", using: :btree
    t.index ["name", "country_id"], name: "index_country_translations_on_name_and_country_id", using: :btree
  end

  create_table "country_vpa_translations", force: :cascade do |t|
    t.integer  "country_vpa_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "name"
    t.text     "description"
    t.index ["country_vpa_id"], name: "index_country_vpa_translations_on_country_vpa_id", using: :btree
    t.index ["locale"], name: "index_country_vpa_translations_on_locale", using: :btree
  end

  create_table "country_vpas", force: :cascade do |t|
    t.string   "url"
    t.boolean  "active",     default: true
    t.integer  "position"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "country_id"
    t.index ["country_id"], name: "index_country_vpas_on_country_id", using: :btree
  end

  create_table "document_files", force: :cascade do |t|
    t.string   "attachment"
    t.string   "file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "faq_translations", force: :cascade do |t|
    t.integer  "faq_id",     null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "question"
    t.text     "answer"
    t.index ["faq_id"], name: "index_faq_translations_on_faq_id", using: :btree
    t.index ["locale"], name: "index_faq_translations_on_locale", using: :btree
  end

  create_table "faqs", force: :cascade do |t|
    t.integer  "position",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "image"
  end

  create_table "fmu_operators", force: :cascade do |t|
    t.integer  "fmu_id",      null: false
    t.integer  "operator_id", null: false
    t.boolean  "current",     null: false
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["fmu_id", "operator_id"], name: "index_fmu_operators_on_fmu_id_and_operator_id", using: :btree
    t.index ["operator_id", "fmu_id"], name: "index_fmu_operators_on_operator_id_and_fmu_id", using: :btree
  end

  create_table "fmu_translations", force: :cascade do |t|
    t.integer  "fmu_id",     null: false
    t.string   "locale",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "name"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_fmu_translations_on_deleted_at", using: :btree
    t.index ["fmu_id"], name: "index_fmu_translations_on_fmu_id", using: :btree
    t.index ["locale"], name: "index_fmu_translations_on_locale", using: :btree
    t.index ["name", "fmu_id"], name: "index_fmu_translations_on_name_and_fmu_id", using: :btree
  end

  create_table "fmus", force: :cascade do |t|
    t.integer  "country_id"
    t.jsonb    "geojson"
    t.datetime "created_at",                                                                 null: false
    t.datetime "updated_at",                                                                 null: false
    t.boolean  "certification_fsc",                                          default: false
    t.boolean  "certification_pefc",                                         default: false
    t.boolean  "certification_olb",                                          default: false
    t.boolean  "certification_pafc",                                         default: false
    t.boolean  "certification_fsc_cw",                                       default: false
    t.boolean  "certification_tlv",                                          default: false
    t.integer  "forest_type",                                                default: 0,     null: false
    t.geometry "geometry",             limit: {:srid=>0, :type=>"geometry"}
    t.jsonb    "properties"
    t.datetime "deleted_at"
    t.boolean  "certification_ls",                                           default: false
    t.index ["country_id"], name: "index_fmus_on_country_id", using: :btree
    t.index ["deleted_at"], name: "index_fmus_on_deleted_at", using: :btree
    t.index ["forest_type"], name: "index_fmus_on_forest_type", using: :btree
  end

  create_table "gov_documents", force: :cascade do |t|
    t.integer  "status",                   null: false
    t.text     "reason"
    t.date     "start_date"
    t.date     "expire_date"
    t.boolean  "current",                  null: false
    t.integer  "uploaded_by"
    t.string   "link"
    t.string   "value"
    t.string   "units"
    t.datetime "deleted_at"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "required_gov_document_id"
    t.integer  "country_id"
    t.integer  "user_id"
    t.index ["country_id"], name: "index_gov_documents_on_country_id", using: :btree
    t.index ["required_gov_document_id"], name: "index_gov_documents_on_required_gov_document_id", using: :btree
    t.index ["user_id"], name: "index_gov_documents_on_user_id", using: :btree
  end

  create_table "gov_files", force: :cascade do |t|
    t.string   "attachment"
    t.datetime "deleted_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "gov_document_id"
    t.index ["gov_document_id"], name: "index_gov_files_on_gov_document_id", using: :btree
  end

  create_table "government_translations", force: :cascade do |t|
    t.integer  "government_id",     null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "government_entity"
    t.text     "details"
    t.index ["government_entity", "government_id"], name: "index_gvt_t_on_government_entity_and_government_id", using: :btree
    t.index ["government_id"], name: "index_government_translations_on_government_id", using: :btree
    t.index ["locale"], name: "index_government_translations_on_locale", using: :btree
  end

  create_table "governments", force: :cascade do |t|
    t.integer  "country_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.boolean  "is_active",  default: true
    t.index ["country_id"], name: "index_governments_on_country_id", using: :btree
  end

  create_table "governments_observations", force: :cascade do |t|
    t.integer  "government_id"
    t.integer  "observation_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["government_id", "observation_id"], name: "governments_observations_association_index", unique: true, using: :btree
    t.index ["government_id"], name: "index_governments_observations_on_government_id", using: :btree
    t.index ["observation_id", "government_id"], name: "observations_governments_association_index", unique: true, using: :btree
    t.index ["observation_id"], name: "index_governments_observations_on_observation_id", using: :btree
  end

  create_table "how_to_translations", force: :cascade do |t|
    t.integer  "how_to_id",   null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.index ["how_to_id"], name: "index_how_to_translations_on_how_to_id", using: :btree
    t.index ["locale"], name: "index_how_to_translations_on_locale", using: :btree
  end

  create_table "how_tos", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "laws", force: :cascade do |t|
    t.text     "written_infraction"
    t.text     "infraction"
    t.text     "sanctions"
    t.integer  "min_fine"
    t.integer  "max_fine"
    t.string   "penal_servitude"
    t.text     "other_penalties"
    t.text     "apv"
    t.integer  "subcategory_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "country_id"
    t.string   "currency"
    t.index ["country_id"], name: "index_laws_on_country_id", using: :btree
    t.index ["max_fine"], name: "index_laws_on_max_fine", using: :btree
    t.index ["min_fine"], name: "index_laws_on_min_fine", using: :btree
    t.index ["subcategory_id"], name: "index_laws_on_subcategory_id", using: :btree
  end

  create_table "observation_documents", force: :cascade do |t|
    t.string   "name"
    t.string   "attachment"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.integer  "observation_id"
    t.index ["deleted_at"], name: "index_observation_documents_on_deleted_at", using: :btree
    t.index ["name"], name: "index_observation_documents_on_name", using: :btree
    t.index ["observation_id"], name: "index_observation_documents_on_observation_id", using: :btree
    t.index ["user_id"], name: "index_observation_documents_on_user_id", using: :btree
  end

  create_table "observation_operators", force: :cascade do |t|
    t.integer  "observation_id"
    t.integer  "operator_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["observation_id"], name: "index_observation_operators_on_observation_id", using: :btree
    t.index ["operator_id"], name: "index_observation_operators_on_operator_id", using: :btree
  end

  create_table "observation_report_observers", force: :cascade do |t|
    t.integer  "observation_report_id"
    t.integer  "observer_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["observation_report_id", "observer_id"], name: "index_obs_rep_id_and_observer_id", using: :btree
    t.index ["observer_id", "observation_report_id"], name: "index_observer_id_and_obs_rep_id", using: :btree
  end

  create_table "observation_reports", force: :cascade do |t|
    t.string   "title"
    t.datetime "publication_date"
    t.string   "attachment"
    t.integer  "user_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_observation_reports_on_deleted_at", using: :btree
    t.index ["title"], name: "index_observation_reports_on_title", using: :btree
    t.index ["user_id"], name: "index_observation_reports_on_user_id", using: :btree
  end

  create_table "observation_translations", force: :cascade do |t|
    t.integer  "observation_id",    null: false
    t.string   "locale",            null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.text     "details"
    t.text     "concern_opinion"
    t.string   "litigation_status"
    t.index ["locale"], name: "index_observation_translations_on_locale", using: :btree
    t.index ["observation_id"], name: "index_observation_translations_on_observation_id", using: :btree
  end

  create_table "observations", force: :cascade do |t|
    t.integer  "severity_id"
    t.integer  "observation_type",                      null: false
    t.integer  "user_id"
    t.datetime "publication_date"
    t.integer  "country_id"
    t.integer  "operator_id"
    t.string   "pv"
    t.boolean  "is_active",             default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.decimal  "lat"
    t.decimal  "lng"
    t.integer  "fmu_id"
    t.integer  "subcategory_id"
    t.integer  "validation_status",     default: 0,     null: false
    t.integer  "observation_report_id"
    t.text     "actions_taken"
    t.integer  "modified_user_id"
    t.integer  "law_id"
    t.string   "location_information"
    t.boolean  "is_physical_place",     default: true
    t.integer  "evidence_type"
    t.integer  "location_accuracy"
    t.string   "evidence_on_report"
    t.boolean  "hidden",                default: false
    t.text     "admin_comment"
    t.text     "monitor_comment"
    t.integer  "responsible_admin_id"
    t.index ["country_id"], name: "index_observations_on_country_id", using: :btree
    t.index ["created_at"], name: "index_observations_on_created_at", using: :btree
    t.index ["evidence_type"], name: "index_observations_on_evidence_type", using: :btree
    t.index ["fmu_id"], name: "index_observations_on_fmu_id", using: :btree
    t.index ["hidden"], name: "index_observations_on_hidden", using: :btree
    t.index ["is_active"], name: "index_observations_on_is_active", using: :btree
    t.index ["is_physical_place"], name: "index_observations_on_is_physical_place", using: :btree
    t.index ["law_id"], name: "index_observations_on_law_id", using: :btree
    t.index ["location_accuracy"], name: "index_observations_on_location_accuracy", using: :btree
    t.index ["observation_report_id"], name: "index_observations_on_observation_report_id", using: :btree
    t.index ["observation_type"], name: "index_observations_on_observation_type", using: :btree
    t.index ["operator_id"], name: "index_observations_on_operator_id", using: :btree
    t.index ["publication_date"], name: "index_observations_on_publication_date", using: :btree
    t.index ["responsible_admin_id"], name: "index_observations_on_responsible_admin_id", using: :btree
    t.index ["severity_id"], name: "index_observations_on_severity_id", using: :btree
    t.index ["updated_at"], name: "index_observations_on_updated_at", using: :btree
    t.index ["user_id"], name: "index_observations_on_user_id", using: :btree
    t.index ["validation_status"], name: "index_observations_on_validation_status", using: :btree
  end

  create_table "observer_observations", force: :cascade do |t|
    t.integer  "observer_id"
    t.integer  "observation_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["observation_id"], name: "index_observer_observations_on_observation_id", using: :btree
    t.index ["observer_id"], name: "index_observer_observations_on_observer_id", using: :btree
  end

  create_table "observer_translations", force: :cascade do |t|
    t.integer  "observer_id",  null: false
    t.string   "locale",       null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "name"
    t.string   "organization"
    t.index ["locale"], name: "index_observer_translations_on_locale", using: :btree
    t.index ["name", "observer_id"], name: "index_observer_translations_on_name_and_observer_id", using: :btree
    t.index ["observer_id"], name: "index_observer_translations_on_observer_id", using: :btree
  end

  create_table "observers", force: :cascade do |t|
    t.string   "observer_type",                     null: false
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "is_active",         default: true
    t.string   "logo"
    t.string   "address"
    t.string   "information_name"
    t.string   "information_email"
    t.string   "information_phone"
    t.string   "data_name"
    t.string   "data_email"
    t.string   "data_phone"
    t.string   "organization_type"
    t.boolean  "public_info",       default: false
    t.index ["is_active"], name: "index_observers_on_is_active", using: :btree
  end

  create_table "operator_document_annexes", force: :cascade do |t|
    t.string   "name"
    t.date     "start_date"
    t.date     "expire_date"
    t.date     "deleted_at"
    t.integer  "status"
    t.string   "attachment"
    t.integer  "uploaded_by"
    t.integer  "user_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "public",      default: true, null: false
    t.index ["deleted_at"], name: "index_operator_document_annexes_on_deleted_at", using: :btree
    t.index ["public"], name: "index_operator_document_annexes_on_public", using: :btree
    t.index ["status"], name: "index_operator_document_annexes_on_status", using: :btree
    t.index ["user_id"], name: "index_operator_document_annexes_on_user_id", using: :btree
  end

  create_table "operator_document_histories", force: :cascade do |t|
    t.string   "type"
    t.date     "expire_date"
    t.date     "start_date"
    t.integer  "status"
    t.integer  "uploaded_by"
    t.text     "reason"
    t.text     "note"
    t.datetime "response_date"
    t.boolean  "public"
    t.integer  "source"
    t.string   "source_info"
    t.integer  "fmu_id"
    t.integer  "document_file_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "operator_document_id"
    t.integer  "operator_id"
    t.integer  "user_id"
    t.integer  "required_operator_document_id"
    t.index ["document_file_id"], name: "index_operator_document_histories_on_document_file_id", using: :btree
    t.index ["expire_date"], name: "index_operator_document_histories_on_expire_date", using: :btree
    t.index ["fmu_id"], name: "index_operator_document_histories_on_fmu_id", using: :btree
    t.index ["operator_document_id"], name: "index_operator_document_histories_on_operator_document_id", using: :btree
    t.index ["operator_id"], name: "index_operator_document_histories_on_operator_id", using: :btree
    t.index ["public"], name: "index_operator_document_histories_on_public", using: :btree
    t.index ["required_operator_document_id"], name: "index_odh_on_rod_id_id", using: :btree
    t.index ["response_date"], name: "index_operator_document_histories_on_response_date", using: :btree
    t.index ["source"], name: "index_operator_document_histories_on_source", using: :btree
    t.index ["status"], name: "index_operator_document_histories_on_status", using: :btree
    t.index ["type"], name: "index_operator_document_histories_on_type", using: :btree
    t.index ["user_id"], name: "index_operator_document_histories_on_user_id", using: :btree
  end

  create_table "operator_documents", force: :cascade do |t|
    t.string   "type"
    t.date     "expire_date"
    t.date     "start_date"
    t.integer  "fmu_id"
    t.integer  "required_operator_document_id"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "status"
    t.integer  "operator_id"
    t.string   "attachment"
    t.boolean  "current"
    t.datetime "deleted_at"
    t.integer  "uploaded_by"
    t.integer  "user_id"
    t.text     "reason"
    t.text     "note"
    t.datetime "response_date"
    t.boolean  "public",                        default: true, null: false
    t.integer  "source",                        default: 1
    t.string   "source_info"
    t.integer  "document_file_id"
    t.index ["current"], name: "index_operator_documents_on_current", using: :btree
    t.index ["deleted_at"], name: "index_operator_documents_on_deleted_at", using: :btree
    t.index ["document_file_id"], name: "index_operator_documents_on_document_file_id", using: :btree
    t.index ["expire_date"], name: "index_operator_documents_on_expire_date", using: :btree
    t.index ["fmu_id"], name: "index_operator_documents_on_fmu_id", using: :btree
    t.index ["operator_id"], name: "index_operator_documents_on_operator_id", using: :btree
    t.index ["public"], name: "index_operator_documents_on_public", using: :btree
    t.index ["required_operator_document_id"], name: "index_operator_documents_on_required_operator_document_id", using: :btree
    t.index ["source"], name: "index_operator_documents_on_source", using: :btree
    t.index ["start_date"], name: "index_operator_documents_on_start_date", using: :btree
    t.index ["status"], name: "index_operator_documents_on_status", using: :btree
    t.index ["type"], name: "index_operator_documents_on_type", using: :btree
  end

  create_table "operator_translations", force: :cascade do |t|
    t.integer  "operator_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "details"
    t.index ["locale"], name: "index_operator_translations_on_locale", using: :btree
    t.index ["name", "operator_id"], name: "index_operator_translations_on_name_and_operator_id", using: :btree
    t.index ["operator_id"], name: "index_operator_translations_on_operator_id", using: :btree
  end

  create_table "operators", force: :cascade do |t|
    t.string   "operator_type"
    t.integer  "country_id"
    t.string   "concession"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "is_active",     default: true
    t.string   "logo"
    t.string   "operator_id"
    t.string   "fa_id"
    t.string   "address"
    t.string   "website"
    t.boolean  "approved",      default: true, null: false
    t.string   "email"
    t.index ["approved"], name: "index_operators_on_approved", using: :btree
    t.index ["country_id"], name: "index_operators_on_country_id", using: :btree
    t.index ["fa_id"], name: "index_operators_on_fa_id", using: :btree
    t.index ["is_active"], name: "index_operators_on_is_active", using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.string   "name"
    t.string   "attachment"
    t.integer  "attacheable_id"
    t.string   "attacheable_type"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "user_id"
    t.index ["attacheable_id", "attacheable_type"], name: "photos_attacheable_index", using: :btree
  end

  create_table "ranking_operator_documents", force: :cascade do |t|
    t.date     "date",                       null: false
    t.boolean  "current",     default: true, null: false
    t.integer  "position",                   null: false
    t.integer  "operator_id"
    t.integer  "country_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["country_id"], name: "index_ranking_operator_documents_on_country_id", using: :btree
    t.index ["current"], name: "index_ranking_operator_documents_on_current", using: :btree
    t.index ["operator_id"], name: "index_ranking_operator_documents_on_operator_id", using: :btree
    t.index ["position", "country_id", "current"], name: "index_rod_on_position_and_country_and_current", using: :btree
  end

  create_table "required_gov_document_group_translations", force: :cascade do |t|
    t.integer  "required_gov_document_group_id", null: false
    t.string   "locale",                         null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "name",                           null: false
    t.text     "description"
    t.index ["locale"], name: "index_required_gov_document_group_translations_on_locale", using: :btree
    t.index ["required_gov_document_group_id"], name: "index_d5783e31f1865cb8918d628281b44e29621b4216", using: :btree
  end

  create_table "required_gov_document_groups", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "required_gov_document_translations", force: :cascade do |t|
    t.integer  "required_gov_document_id", null: false
    t.string   "locale",                   null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "explanation"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_required_gov_document_translations_on_deleted_at", using: :btree
    t.index ["locale"], name: "index_required_gov_document_translations_on_locale", using: :btree
    t.index ["required_gov_document_id"], name: "index_759a54fdd00cf06c291ffc4857fb904934dd47b9", using: :btree
  end

  create_table "required_gov_documents", force: :cascade do |t|
    t.string   "name",                           null: false
    t.integer  "document_type",                  null: false
    t.integer  "valid_period"
    t.datetime "deleted_at"
    t.integer  "required_gov_document_group_id"
    t.integer  "country_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["country_id"], name: "index_required_gov_documents_on_country_id", using: :btree
    t.index ["deleted_at"], name: "index_required_gov_documents_on_deleted_at", using: :btree
    t.index ["document_type"], name: "index_required_gov_documents_on_document_type", using: :btree
    t.index ["required_gov_document_group_id"], name: "index_required_gov_documents_on_required_gov_document_group_id", using: :btree
  end

  create_table "required_operator_document_group_translations", force: :cascade do |t|
    t.integer  "required_operator_document_group_id", null: false
    t.string   "locale",                              null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.index ["locale"], name: "index_required_operator_document_group_translations_on_locale", using: :btree
    t.index ["required_operator_document_group_id"], name: "index_64b55c0cec158f1717cc5d775ae87c7a48f1cc59", using: :btree
  end

  create_table "required_operator_document_groups", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
  end

  create_table "required_operator_document_translations", force: :cascade do |t|
    t.integer  "required_operator_document_id", null: false
    t.string   "locale",                        null: false
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.text     "explanation"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_required_operator_document_translations_on_deleted_at", using: :btree
    t.index ["locale"], name: "index_required_operator_document_translations_on_locale", using: :btree
    t.index ["required_operator_document_id"], name: "index_eed74ed5a0934f32c4b075e5beee98f1ebf34d19", using: :btree
  end

  create_table "required_operator_documents", force: :cascade do |t|
    t.string   "type"
    t.integer  "required_operator_document_group_id"
    t.string   "name"
    t.integer  "country_id"
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
    t.integer  "valid_period"
    t.datetime "deleted_at"
    t.integer  "forest_types",                        default: [],                 array: true
    t.boolean  "contract_signature",                  default: false, null: false
    t.index ["contract_signature"], name: "index_required_operator_documents_on_contract_signature", using: :btree
    t.index ["deleted_at"], name: "index_required_operator_documents_on_deleted_at", using: :btree
    t.index ["forest_types"], name: "index_required_operator_documents_on_forest_types", using: :btree
    t.index ["required_operator_document_group_id"], name: "index_req_op_doc_group_id", using: :btree
    t.index ["type"], name: "index_required_operator_documents_on_type", using: :btree
  end

  create_table "sawmills", force: :cascade do |t|
    t.string   "name"
    t.float    "lat"
    t.float    "lng"
    t.boolean  "is_active",   default: true, null: false
    t.integer  "operator_id",                null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.jsonb    "geojson"
  end

  create_table "score_operator_documents", force: :cascade do |t|
    t.date     "date",                           null: false
    t.boolean  "current",         default: true, null: false
    t.float    "all"
    t.float    "country"
    t.float    "fmu"
    t.jsonb    "summary_public"
    t.jsonb    "summary_private"
    t.integer  "total"
    t.integer  "operator_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["current"], name: "index_score_operator_documents_on_current", using: :btree
    t.index ["date"], name: "index_score_operator_documents_on_date", using: :btree
    t.index ["operator_id"], name: "index_score_operator_documents_on_operator_id", using: :btree
  end

  create_table "score_operator_observations", force: :cascade do |t|
    t.date     "date",                         null: false
    t.boolean  "current",       default: true, null: false
    t.float    "score"
    t.float    "obs_per_visit"
    t.integer  "operator_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["current", "operator_id"], name: "index_score_operator_observations_on_current_and_operator_id", using: :btree
    t.index ["current"], name: "index_score_operator_observations_on_current", using: :btree
    t.index ["date"], name: "index_score_operator_observations_on_date", using: :btree
    t.index ["operator_id"], name: "index_score_operator_observations_on_operator_id", using: :btree
  end

  create_table "severities", force: :cascade do |t|
    t.integer  "level"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "subcategory_id"
    t.index ["level", "id"], name: "index_severities_on_level_and_id", using: :btree
    t.index ["level", "subcategory_id"], name: "index_severities_on_level_and_subcategory_id", using: :btree
    t.index ["level"], name: "index_severities_on_level", using: :btree
    t.index ["subcategory_id", "level"], name: "index_severities_on_subcategory_id_and_level", using: :btree
  end

  create_table "severity_translations", force: :cascade do |t|
    t.integer  "severity_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "details"
    t.index ["locale"], name: "index_severity_translations_on_locale", using: :btree
    t.index ["severity_id"], name: "index_severity_translations_on_severity_id", using: :btree
  end

  create_table "species", force: :cascade do |t|
    t.string   "name"
    t.string   "species_class"
    t.string   "sub_species"
    t.string   "species_family"
    t.string   "species_kingdom"
    t.string   "scientific_name"
    t.string   "cites_status"
    t.integer  "cites_id"
    t.integer  "iucn_status"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "species_countries", force: :cascade do |t|
    t.integer  "country_id"
    t.integer  "species_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_species_countries_on_country_id", using: :btree
    t.index ["species_id"], name: "index_species_countries_on_species_id", using: :btree
  end

  create_table "species_observations", force: :cascade do |t|
    t.integer  "observation_id"
    t.integer  "species_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["observation_id"], name: "index_species_observations_on_observation_id", using: :btree
    t.index ["species_id"], name: "index_species_observations_on_species_id", using: :btree
  end

  create_table "species_translations", force: :cascade do |t|
    t.integer  "species_id",  null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "common_name"
    t.index ["locale"], name: "index_species_translations_on_locale", using: :btree
    t.index ["species_id"], name: "index_species_translations_on_species_id", using: :btree
  end

  create_table "subcategories", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "subcategory_type"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.boolean  "location_required", default: true
    t.index ["category_id"], name: "index_subcategories_on_category_id", using: :btree
    t.index ["subcategory_type"], name: "index_subcategories_on_subcategory_type", using: :btree
  end

  create_table "subcategory_translations", force: :cascade do |t|
    t.integer  "subcategory_id", null: false
    t.string   "locale",         null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "name"
    t.text     "details"
    t.index ["locale"], name: "index_subcategory_translations_on_locale", using: :btree
    t.index ["name", "subcategory_id"], name: "index_subcategory_translations_on_name_and_subcategory_id", using: :btree
    t.index ["subcategory_id"], name: "index_subcategory_translations_on_subcategory_id", using: :btree
  end

  create_table "tool_translations", force: :cascade do |t|
    t.integer  "tool_id",     null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.index ["locale"], name: "index_tool_translations_on_locale", using: :btree
    t.index ["tool_id"], name: "index_tool_translations_on_tool_id", using: :btree
  end

  create_table "tools", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tutorial_translations", force: :cascade do |t|
    t.integer  "tutorial_id", null: false
    t.string   "locale",      null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "name"
    t.text     "description"
    t.index ["locale"], name: "index_tutorial_translations_on_locale", using: :btree
    t.index ["tutorial_id"], name: "index_tutorial_translations_on_tutorial_id", using: :btree
  end

  create_table "tutorials", force: :cascade do |t|
    t.integer  "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "uploaded_documents", force: :cascade do |t|
    t.string   "name"
    t.string   "author"
    t.string   "caption"
    t.string   "file"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_permissions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "user_role",   default: 0,  null: false
    t.jsonb    "permissions", default: {}
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "nickname"
    t.string   "name"
    t.string   "institution"
    t.string   "web_url"
    t.boolean  "is_active",              default: true
    t.datetime "deactivated_at"
    t.integer  "permissions_request"
    t.datetime "permissions_accepted"
    t.integer  "country_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "encrypted_password",     default: "",   null: false
    t.datetime "remember_created_at"
    t.integer  "observer_id"
    t.integer  "operator_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["name"], name: "index_users_on_name", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",      null: false
    t.bigint   "item_id",        null: false
    t.string   "event",          null: false
    t.string   "whodunnit"
    t.text     "object"
    t.string   "locale"
    t.datetime "created_at"
    t.text     "object_changes"
    t.index ["item_type", "item_id", "locale"], name: "index_versions_on_item_type_and_item_id_and_locale", using: :btree
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "annex_documents", "operator_document_annexes", on_delete: :cascade
  add_foreign_key "api_keys", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "country_links", "countries", on_delete: :cascade
  add_foreign_key "country_vpas", "countries", on_delete: :cascade
  add_foreign_key "gov_documents", "countries", on_delete: :cascade
  add_foreign_key "gov_documents", "required_gov_documents", on_delete: :cascade
  add_foreign_key "gov_documents", "users", on_delete: :cascade
  add_foreign_key "gov_files", "gov_documents", on_delete: :cascade
  add_foreign_key "laws", "countries"
  add_foreign_key "laws", "subcategories"
  add_foreign_key "observation_documents", "observations"
  add_foreign_key "observation_documents", "users"
  add_foreign_key "observation_operators", "observations"
  add_foreign_key "observation_operators", "operators"
  add_foreign_key "observation_report_observers", "observation_reports"
  add_foreign_key "observation_report_observers", "observers"
  add_foreign_key "observation_reports", "users"
  add_foreign_key "observations", "countries"
  add_foreign_key "observations", "fmus"
  add_foreign_key "observations", "laws"
  add_foreign_key "observations", "observation_reports"
  add_foreign_key "observations", "operators"
  add_foreign_key "observations", "users"
  add_foreign_key "observations", "users", column: "modified_user_id"
  add_foreign_key "operator_document_histories", "operator_documents", on_delete: :nullify
  add_foreign_key "operator_document_histories", "operators", on_delete: :cascade
  add_foreign_key "operator_document_histories", "required_operator_documents", on_delete: :cascade
  add_foreign_key "operator_document_histories", "users", on_delete: :nullify
  add_foreign_key "operator_documents", "fmus"
  add_foreign_key "operator_documents", "operators"
  add_foreign_key "operator_documents", "required_operator_documents"
  add_foreign_key "operator_documents", "users", on_delete: :nullify
  add_foreign_key "photos", "users"
  add_foreign_key "ranking_operator_documents", "countries", on_delete: :cascade
  add_foreign_key "ranking_operator_documents", "operators", on_delete: :cascade
  add_foreign_key "required_gov_documents", "countries", on_delete: :cascade
  add_foreign_key "required_gov_documents", "required_gov_document_groups", on_delete: :cascade
  add_foreign_key "required_operator_documents", "countries"
  add_foreign_key "required_operator_documents", "required_operator_document_groups"
  add_foreign_key "sawmills", "operators"
  add_foreign_key "score_operator_documents", "operators", on_delete: :cascade
  add_foreign_key "score_operator_observations", "operators", on_delete: :cascade
  add_foreign_key "severities", "subcategories"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "user_permissions", "users"
  add_foreign_key "users", "countries"
end
