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

ActiveRecord::Schema.define(version: 20170916170623) do

  create_table "drivers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", force: :cascade do |t|
    t.string   "sport"
    t.string   "description"
    t.string   "first_option"
    t.string   "second_option"
    t.string   "winner"
    t.string   "heat"
    t.string   "first_option_chosen"
    t.string   "second_option_chosen"
    t.string   "first_final"
    t.string   "second_final"
    t.string   "comments_count"
    t.string   "date"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password"
    t.float    "threshold"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
