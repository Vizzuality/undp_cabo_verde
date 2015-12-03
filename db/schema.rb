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

ActiveRecord::Schema.define(version: 20151203170724) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "act_actor_relations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "act_id"
    t.integer  "actor_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "relation_type_id"
  end

  add_index "act_actor_relations", ["act_id", "actor_id"], name: "index_act_actor", unique: true, using: :btree
  add_index "act_actor_relations", ["act_id"], name: "index_act_actor_relations_on_act_id", using: :btree
  add_index "act_actor_relations", ["actor_id"], name: "index_act_actor_relations_on_actor_id", using: :btree
  add_index "act_actor_relations", ["user_id"], name: "index_act_actor_relations_on_user_id", using: :btree

  create_table "act_localizations", force: :cascade do |t|
    t.integer  "localization_id"
    t.integer  "act_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "act_localizations", ["act_id"], name: "index_act_localizations_on_act_id", using: :btree
  add_index "act_localizations", ["localization_id"], name: "index_act_localizations_on_localization_id", using: :btree

  create_table "act_relations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "relation_type_id"
  end

  add_index "act_relations", ["child_id"], name: "index_act_relations_on_child_id", using: :btree
  add_index "act_relations", ["parent_id", "child_id"], name: "index_act_parent_child", unique: true, using: :btree
  add_index "act_relations", ["parent_id"], name: "index_act_relations_on_parent_id", using: :btree
  add_index "act_relations", ["user_id"], name: "index_act_relations_on_user_id", using: :btree

  create_table "actor_localizations", force: :cascade do |t|
    t.integer  "localization_id"
    t.integer  "actor_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "actor_localizations", ["actor_id"], name: "index_actor_localizations_on_actor_id", using: :btree
  add_index "actor_localizations", ["localization_id"], name: "index_actor_localizations_on_localization_id", using: :btree

  create_table "actor_relations", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "relation_type_id"
  end

  add_index "actor_relations", ["child_id"], name: "index_actor_relations_on_child_id", using: :btree
  add_index "actor_relations", ["parent_id", "child_id"], name: "index_actor_parent_child", unique: true, using: :btree
  add_index "actor_relations", ["parent_id"], name: "index_actor_relations_on_parent_id", using: :btree
  add_index "actor_relations", ["user_id"], name: "index_actor_relations_on_user_id", using: :btree

  create_table "actors", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",                             null: false
    t.string   "name",                             null: false
    t.boolean  "active",            default: true, null: false
    t.datetime "deactivated_at"
    t.text     "observation"
    t.integer  "gender",            default: 1
    t.integer  "operational_field", default: 1
    t.integer  "title",             default: 1
    t.datetime "date_of_birth"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "short_name"
    t.string   "legal_status"
    t.string   "other_names"
  end

  add_index "actors", ["type"], name: "index_actors_on_type", using: :btree
  add_index "actors", ["user_id"], name: "index_actors_on_user_id", using: :btree

  create_table "actors_categories", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "actor_id"
  end

  create_table "acts", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",                             null: false
    t.string   "name",                             null: false
    t.string   "alternative_name"
    t.string   "short_name"
    t.boolean  "event",            default: false
    t.boolean  "human",            default: false
    t.boolean  "active",           default: true,  null: false
    t.datetime "deactivated_at"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "action_type"
    t.string   "budget"
  end

  add_index "acts", ["type"], name: "index_acts_on_type", using: :btree
  add_index "acts", ["user_id"], name: "index_acts_on_user_id", using: :btree

  create_table "acts_categories", id: false, force: :cascade do |t|
    t.integer "category_id"
    t.integer "act_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "admin_users", ["user_id"], name: "index_admin_users_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "type",       null: false
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "body",                            null: false
    t.boolean  "active",           default: true, null: false
    t.datetime "deactivated_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "comments", ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "localizations", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "active",         default: true, null: false
    t.datetime "deactivated_at"
    t.string   "country"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.string   "district"
    t.string   "name"
    t.string   "lat"
    t.string   "long"
    t.string   "web_url"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "localizations", ["user_id"], name: "index_localizations_on_user_id", using: :btree

  create_table "relation_types", force: :cascade do |t|
    t.integer  "relation_category"
    t.string   "title"
    t.string   "title_reverse"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "firstname"
    t.string   "lastname"
    t.string   "institution"
    t.boolean  "active",                 default: true, null: false
    t.datetime "deactivated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "act_actor_relations", "users"
  add_foreign_key "act_relations", "users"
  add_foreign_key "actor_relations", "users"
  add_foreign_key "actors", "users"
  add_foreign_key "acts", "users"
  add_foreign_key "admin_users", "users"
  add_foreign_key "comments", "users"
  add_foreign_key "localizations", "users"
end
