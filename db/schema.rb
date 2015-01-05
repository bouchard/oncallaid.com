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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121208222149) do

  create_table "article_versions", :force => true do |t|
    t.string   "item_type",                    :null => false
    t.integer  "item_id",                      :null => false
    t.string   "event",                        :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.integer  "diff_word_size",               :null => false
    t.integer  "diff_line_size",               :null => false
    t.string   "ip",             :limit => 16
  end

  add_index "article_versions", ["item_type", "item_id"], :name => "index_article_versions_on_item_type_and_item_id"

  create_table "articles", :force => true do |t|
    t.string   "title",                         :null => false
    t.string   "sort_title",                    :null => false
    t.string   "slug",                          :null => false
    t.text     "body"
    t.boolean  "deleted",    :default => false
    t.boolean  "empty",      :default => true
    t.integer  "chapter_id",                    :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.string   "token"
    t.string   "friendly_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "authorizations", ["uid"], :name => "index_authorizations_on_uid"
  add_index "authorizations", ["user_id"], :name => "index_authorizations_on_user_id"

  create_table "chapters", :force => true do |t|
    t.string   "title",      :null => false
    t.string   "slug",       :null => false
    t.integer  "sort_order"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "contributions", :force => true do |t|
    t.integer  "user_id",                                        :null => false
    t.integer  "article_id",                                     :null => false
    t.integer  "article_version_id",                             :null => false
    t.integer  "word_size",          :limit => 8, :default => 0
    t.integer  "line_size",          :limit => 8, :default => 0
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "contributions", ["article_id"], :name => "index_contributions_on_article_id"
  add_index "contributions", ["article_version_id"], :name => "index_contributions_on_article_version_id"
  add_index "contributions", ["user_id"], :name => "index_contributions_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "profiles", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.string   "name",         :null => false
    t.string   "postnominals"
    t.string   "description",  :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "title"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "submissions", :force => true do |t|
    t.integer  "user_id",                                :null => false
    t.integer  "article_id"
    t.string   "title"
    t.text     "body"
    t.string   "status",          :default => "pending"
    t.text     "rejected_reason"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "username",                               :null => false
    t.string   "roles",                                  :null => false
    t.string   "friend_uids"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
