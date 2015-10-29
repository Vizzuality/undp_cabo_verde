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

ActiveRecord::Schema.define(version: 20151028153403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "actors", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type",                             null: false
    t.string   "name",                             null: false
    t.boolean  "active",            default: true, null: false
    t.datetime "deactivated_at"
    t.text     "observation"
    t.integer  "gender",            default: 1
    t.integer  "operational_filed", default: 1
    t.integer  "title",             default: 1
    t.datetime "date_of_birth"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "actors", ["type"], name: "index_actors_on_type", using: :btree
  add_index "actors", ["user_id"], name: "index_actors_on_user_id", using: :btree

  create_table "actors_macro_meso_relations", force: :cascade do |t|
    t.integer  "macro_id"
    t.integer  "meso_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "actors_macro_meso_relations", ["macro_id"], name: "index_actors_macro_meso_relations_on_macro_id", using: :btree
  add_index "actors_macro_meso_relations", ["meso_id"], name: "index_actors_macro_meso_relations_on_meso_id", using: :btree

  create_table "actors_macro_micro_relations", force: :cascade do |t|
    t.integer  "macro_id"
    t.integer  "micro_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "actors_macro_micro_relations", ["macro_id"], name: "index_actors_macro_micro_relations_on_macro_id", using: :btree
  add_index "actors_macro_micro_relations", ["micro_id"], name: "index_actors_macro_micro_relations_on_micro_id", using: :btree

  create_table "actors_meso_micro_relations", force: :cascade do |t|
    t.integer  "meso_id"
    t.integer  "micro_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "actors_meso_micro_relations", ["meso_id"], name: "index_actors_meso_micro_relations_on_meso_id", using: :btree
  add_index "actors_meso_micro_relations", ["micro_id"], name: "index_actors_meso_micro_relations_on_micro_id", using: :btree

  create_table "admin_users", force: :cascade do |t|
    t.integer "user_id"
  end

  add_index "admin_users", ["user_id"], name: "index_admin_users_on_user_id", using: :btree

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

  add_foreign_key "actors", "users"
  add_foreign_key "admin_users", "users"
end
