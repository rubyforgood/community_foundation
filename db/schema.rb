# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_28_183247) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "allocation_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.integer "parent_id"
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "type"], name: "index_allocation_categories_on_organization_id_and_type"
    t.index ["organization_id"], name: "index_allocation_categories_on_organization_id"
    t.index ["parent_id"], name: "index_allocation_categories_on_parent_id"
  end

  create_table "allocation_preferences", force: :cascade do |t|
    t.integer "allocation_category_id", null: false
    t.integer "allocation_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["allocation_category_id"], name: "index_allocation_preferences_on_allocation_category_id"
    t.index ["allocation_id", "allocation_category_id"], name: "index_allocation_preferences_uniqueness", unique: true
    t.index ["allocation_id"], name: "index_allocation_preferences_on_allocation_id"
  end

  create_table "allocations", force: :cascade do |t|
    t.integer "allocation_category_id"
    t.integer "amount"
    t.datetime "created_at", null: false
    t.text "note"
    t.string "option"
    t.integer "percentage"
    t.integer "scenario_id", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
    t.index ["allocation_category_id"], name: "index_allocations_on_allocation_category_id"
    t.index ["scenario_id"], name: "index_allocations_on_scenario_id"
  end

  create_table "organization_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "organization_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["user_id", "organization_id"], name: "index_organization_memberships_on_user_id_and_organization_id", unique: true
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
  end

  create_table "organizations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["subdomain"], name: "index_organizations_on_subdomain", unique: true
  end

  create_table "scenarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "organization_id", null: false
    t.string "share_token"
    t.integer "total_giving_amount"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["organization_id"], name: "index_scenarios_on_organization_id"
    t.index ["share_token"], name: "index_scenarios_on_share_token", unique: true
    t.index ["user_id"], name: "index_scenarios_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "user_biographies", force: :cascade do |t|
    t.text "background"
    t.date "birth_date"
    t.string "birthplace"
    t.text "civic_organizations"
    t.datetime "created_at", null: false
    t.text "education"
    t.text "employment_history"
    t.text "family_members"
    t.text "formative_experiences"
    t.text "hobbies"
    t.text "marriages"
    t.text "military_service"
    t.text "other"
    t.text "other_places_lived"
    t.text "parents"
    t.text "professional_licenses"
    t.text "religious_affiliations"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.text "what_brought_you_here"
    t.index ["user_id"], name: "index_user_biographies_on_user_id", unique: true
  end

  create_table "user_legacy_stories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.text "supported_organizations"
    t.text "important_nonprofits"
    t.text "additional_giving_notes"
    t.text "childhood_generosity"
    t.text "influential_people"
    t.text "other_motivations"
    t.text "family_lessons"
    t.text "life_lessons"
    t.text "passions"
    t.text "core_values"
    t.text "legacy_memory"
    t.text "unasked_questions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_legacy_stories_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "background"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.text "family"
    t.text "formative_experiences"
    t.string "name"
    t.string "password_digest"
    t.boolean "super_admin", default: false, null: false
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "allocation_categories", "allocation_categories", column: "parent_id"
  add_foreign_key "allocation_categories", "organizations"
  add_foreign_key "allocation_preferences", "allocation_categories"
  add_foreign_key "allocation_preferences", "allocations"
  add_foreign_key "allocations", "allocation_categories"
  add_foreign_key "allocations", "scenarios"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "scenarios", "organizations"
  add_foreign_key "scenarios", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "user_biographies", "users"
  add_foreign_key "user_legacy_stories", "users"
end
