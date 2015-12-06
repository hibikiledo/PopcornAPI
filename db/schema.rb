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

ActiveRecord::Schema.define(version: 20151201013144) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "movies", force: :cascade do |t|
    t.string   "imdb_id",     limit: 255
    t.string   "title",       limit: 255
    t.string   "year",        limit: 255
    t.string   "rating",      limit: 255
    t.string   "runtime",     limit: 255
    t.string   "genre",       limit: 255
    t.date     "released"
    t.string   "director",    limit: 255
    t.string   "writer",      limit: 255
    t.string   "cast",        limit: 255
    t.string   "metacritic",  limit: 255
    t.float    "imdb_rating", limit: 24
    t.integer  "imdb_votes",  limit: 4
    t.string   "poster_url",  limit: 255
    t.text     "plot",        limit: 65535
    t.text     "full_plot",   limit: 65535
    t.string   "language",    limit: 255
    t.string   "country",     limit: 255
    t.string   "awards",      limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,     null: false
    t.integer  "movie_id",   limit: 4,     null: false
    t.text     "comment",    limit: 65535
    t.integer  "stars",      limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "reviews", ["movie_id"], name: "index_reviews_on_movie_id", using: :btree
  add_index "reviews", ["user_id"], name: "index_reviews_on_user_id", using: :btree

  create_table "suggestions", force: :cascade do |t|
    t.integer  "user_id",    limit: 4, null: false
    t.integer  "movie_id",   limit: 4, null: false
    t.integer  "stars",      limit: 4, null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "suggestions", ["movie_id"], name: "index_suggestions_on_movie_id", using: :btree
  add_index "suggestions", ["user_id"], name: "index_suggestions_on_user_id", using: :btree

  create_table "user_connections", id: false, force: :cascade do |t|
    t.integer "user_a_id", limit: 4, null: false
    t.integer "user_b_id", limit: 4, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "readable_id", limit: 255
    t.string   "email",       limit: 255
    t.string   "password",    limit: 255
    t.string   "profile_pic", limit: 255
    t.string   "token",       limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

end
