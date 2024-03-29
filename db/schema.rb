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

ActiveRecord::Schema.define(version: 20171118041347) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "commissions", force: :cascade do |t|
    t.integer  "project_id"
    t.float    "percentage"
    t.date     "effective_date"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["id", "project_id"], name: "index_commissions_on_id_and_project_id", using: :btree
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sales", force: :cascade do |t|
    t.date     "date",                        null: false
    t.string   "buyer"
    t.integer  "project_id",                  null: false
    t.integer  "unit_id"
    t.integer  "status",          default: 0
    t.string   "package"
    t.string   "remark"
    t.date     "spa_sign_date"
    t.date     "la_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "commission_id"
    t.string   "unit_no"
    t.integer  "size"
    t.integer  "nett_price",                  null: false
    t.integer  "spa_price",                   null: false
    t.float    "comm"
    t.float    "comm_percentage"
    t.index ["commission_id"], name: "index_sales_on_commission_id", using: :btree
    t.index ["date"], name: "index_sales_on_date", using: :btree
    t.index ["project_id"], name: "index_sales_on_project_id", using: :btree
    t.index ["unit_id"], name: "index_sales_on_unit_id", using: :btree
  end

  create_table "salevalues", force: :cascade do |t|
    t.float    "percentage"
    t.float    "nett_value"
    t.float    "spa"
    t.float    "comm"
    t.integer  "user_id"
    t.integer  "sale_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "other_user"
    t.index ["sale_id"], name: "index_salevalues_on_sale_id", using: :btree
    t.index ["user_id"], name: "index_salevalues_on_user_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "name"
    t.integer  "leader_id"
    t.string   "ancestry"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ancestry"], name: "index_teams_on_ancestry", using: :btree
    t.index ["leader_id"], name: "index_teams_on_leader_id", using: :btree
  end

  create_table "units", force: :cascade do |t|
    t.string   "unit_no"
    t.integer  "size"
    t.float    "nett_price"
    t.float    "spa_price"
    t.float    "comm"
    t.float    "comm_percentage"
    t.integer  "project_id"
    t.integer  "sale_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["id", "project_id"], name: "index_units_on_id_and_project_id", using: :btree
    t.index ["id", "sale_id"], name: "index_units_on_id_and_sale_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "encrypted_password"
    t.string   "name"
    t.string   "prefered_name",                          null: false
    t.string   "phone_no"
    t.date     "birthday"
    t.integer  "team_id"
    t.integer  "location"
    t.integer  "position"
    t.boolean  "approved?",              default: false
    t.string   "ancestry"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.boolean  "leader?",                default: false
    t.index ["ancestry"], name: "index_users_on_ancestry", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["prefered_name"], name: "index_users_on_prefered_name", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["team_id"], name: "index_users_on_team_id", using: :btree
  end

  create_table "websites", force: :cascade do |t|
    t.string   "subdomain"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "superteam_name"
    t.string   "logo"
    t.string   "external_host"
    t.string   "email"
    t.string   "password"
    t.string   "password_digest"
  end

end
