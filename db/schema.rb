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

ActiveRecord::Schema.define(version: 20170202055454) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "subdomain"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email"
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  add_index "admin_users", ["subdomain"], name: "index_admin_users_on_subdomain", unique: true

  create_table "admin_users_roles", id: false, force: true do |t|
    t.integer "admin_user_id"
    t.integer "role_id"
  end

  add_index "admin_users_roles", ["admin_user_id", "role_id"], name: "index_admin_users_roles_on_admin_user_id_and_role_id"

  create_table "adminuser_users", force: true do |t|
    t.integer  "admin_user_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "adminuser_users", ["admin_user_id"], name: "index_adminuser_users_on_admin_user_id"
  add_index "adminuser_users", ["user_id"], name: "index_adminuser_users_on_user_id"

  create_table "advertises", force: true do |t|
    t.text     "body"
    t.integer  "language_id"
    t.datetime "start_time"
    t.datetime "expiration_time"
    t.boolean  "programmer_only", default: false
    t.integer  "skill_id"
    t.boolean  "is_active",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gender"
    t.string   "country"
    t.string   "close_text"
    t.integer  "views",           default: 0
    t.integer  "clicks",          default: 0
  end

  add_index "advertises", ["language_id"], name: "index_advertises_on_language_id"
  add_index "advertises", ["skill_id"], name: "index_advertises_on_skill_id"

  create_table "authentication_providers", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "authentication_providers", ["name"], name: "index_name_on_authentication_providers"

  create_table "course_levels", force: true do |t|
    t.integer  "course_id"
    t.string   "title"
    t.text     "description"
    t.text     "question"
    t.text     "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "predefined_answer"
    t.boolean  "case_sensitive",                 default: false
    t.boolean  "regular_expression",             default: false
    t.text     "error_message",      limit: 255
    t.text     "congratulations"
    t.integer  "position"
    t.integer  "level_type",                     default: 0
  end

  add_index "course_levels", ["course_id"], name: "index_course_levels_on_course_id"

  create_table "courses", force: true do |t|
    t.integer  "instructor_id"
    t.integer  "language_id"
    t.string   "title"
    t.text     "description"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "is_published",        default: false
    t.boolean  "is_approved",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "congratulations"
    t.integer  "course_type",         default: 0
  end

  add_index "courses", ["instructor_id"], name: "index_courses_on_instructor_id"
  add_index "courses", ["language_id"], name: "index_courses_on_language_id"

  create_table "invites", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.text     "body"
    t.boolean  "sent",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invites", ["user_id"], name: "index_invites_on_user_id"

  create_table "jobs", force: true do |t|
    t.integer  "user_id"
    t.text     "description"
    t.string   "title"
    t.string   "country"
    t.string   "city"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "is_published",        default: false
    t.boolean  "is_approved",         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "languages", force: true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.boolean  "sender_deleted",    default: false
    t.boolean  "recipient_deleted", default: false
    t.string   "subject"
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_read",           default: false
    t.boolean  "system_message",    default: false
    t.boolean  "is_send",           default: false
  end

  add_index "messages", ["recipient_id"], name: "index_messages_on_recipient_id"
  add_index "messages", ["sender_id"], name: "index_messages_on_sender_id"

  create_table "profile_accesses", force: true do |t|
    t.integer  "from"
    t.integer  "to"
    t.boolean  "allow",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_accesses", ["from"], name: "index_profile_accesses_on_from"
  add_index "profile_accesses", ["to"], name: "index_profile_accesses_on_to"

  create_table "profile_views", force: true do |t|
    t.integer  "from"
    t.integer  "to"
    t.datetime "last_view"
    t.integer  "view_count", default: 0
    t.boolean  "is_read",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_views", ["from"], name: "index_profile_views_on_from"
  add_index "profile_views", ["to"], name: "index_profile_views_on_to"

  create_table "report_abuses", force: true do |t|
    t.integer  "from"
    t.integer  "to"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], name: "index_roles_on_name"

  create_table "skill_questions", force: true do |t|
    t.integer  "skill_id"
    t.text     "question",    limit: 255
    t.string   "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
  end

  add_index "skill_questions", ["language_id"], name: "index_skill_questions_on_language_id"
  add_index "skill_questions", ["skill_id"], name: "index_skill_questions_on_skill_id"

  create_table "skill_traits", force: true do |t|
    t.integer  "skill_id"
    t.integer  "trait_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skill_traits", ["skill_id"], name: "index_skill_traits_on_skill_id"
  add_index "skill_traits", ["trait_id"], name: "index_skill_traits_on_trait_id"

  create_table "skills", force: true do |t|
    t.integer  "language_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "index"
  end

  add_index "skills", ["language_id"], name: "index_skills_on_language_id"

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "tips", force: true do |t|
    t.integer  "language_id"
    t.text     "content"
    t.boolean  "for_girl",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tips", ["language_id"], name: "index_tips_on_language_id"

  create_table "traits", force: true do |t|
    t.integer  "language_id"
    t.string   "name"
    t.integer  "index"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "traits", ["language_id"], name: "index_traits_on_language_id"

  create_table "user_authentications", force: true do |t|
    t.integer  "user_id"
    t.integer  "authentication_provider_id"
    t.string   "uid"
    t.string   "token"
    t.datetime "token_expires_at"
    t.text     "params"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "user_authentications", ["authentication_provider_id"], name: "index_user_authentications_on_authentication_provider_id"
  add_index "user_authentications", ["user_id"], name: "index_user_authentications_on_user_id"

  create_table "user_courses", force: true do |t|
    t.integer  "user_id"
    t.integer  "course_id"
    t.integer  "passed_levels", default: 0
    t.boolean  "is_completed",  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_courses", ["course_id", "user_id"], name: "index_user_courses_on_course_id_and_user_id"
  add_index "user_courses", ["course_id"], name: "index_user_courses_on_course_id"
  add_index "user_courses", ["user_id"], name: "index_user_courses_on_user_id"

  create_table "user_details", force: true do |t|
    t.integer  "user_id"
    t.text     "from",                 limit: 3072
    t.text     "fav_movie",            limit: 3072
    t.text     "last_movie",           limit: 3072
    t.text     "last_book",            limit: 3072
    t.text     "fav_singer",           limit: 3072
    t.text     "make_laugh"
    t.text     "make_cry"
    t.text     "like_animals",         limit: 3072
    t.text     "my_dream"
    t.text     "like_live",            limit: 3072
    t.string   "skype_name"
    t.string   "facebook_link"
    t.text     "social_network_links"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar1_file_name"
    t.string   "avatar1_content_type"
    t.integer  "avatar1_file_size"
    t.datetime "avatar1_updated_at"
    t.string   "avatar2_file_name"
    t.string   "avatar2_content_type"
    t.integer  "avatar2_file_size"
    t.datetime "avatar2_updated_at"
  end

  add_index "user_details", ["user_id"], name: "index_user_details_on_user_id"

  create_table "users", force: true do |t|
    t.string   "username",               default: ""
    t.text     "about_me",               default: ""
    t.integer  "age",                    default: 0
    t.string   "country",                default: ""
    t.string   "city",                   default: ""
    t.string   "email",                  default: "",                    null: false
    t.string   "encrypted_password",     default: "",                    null: false
    t.boolean  "is_girl",                default: true,                  null: false
    t.integer  "skill_id",               default: 0
    t.text     "traits",                 default: ""
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,                     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "notification",           default: true
    t.string   "notification_token"
    t.boolean  "invitation",             default: false
    t.boolean  "is_active",              default: true
    t.integer  "girl_match_skill_id"
    t.datetime "last_sign_out_at"
    t.integer  "gender",                 default: 0
    t.integer  "looking_for",            default: 0
    t.boolean  "system_message",         default: true
    t.boolean  "profile_activity",       default: true
    t.boolean  "site_news",              default: true
    t.integer  "report_abuse",           default: 0
    t.integer  "unread_message_count",   default: 0
    t.integer  "profile_viewed_count",   default: 0
    t.integer  "points",                 default: 0
    t.string   "referral_code"
    t.text     "filter"
    t.float    "battery_size",           default: 100.0
    t.datetime "battery_date",           default: '2017-01-25 05:40:28', null: false
    t.boolean  "notification_profile",   default: true
    t.string   "locale"
    t.integer  "profile_views",          default: 0
    t.integer  "referral_count",         default: 1
    t.integer  "referred_user_id"
    t.boolean  "freeze_account",         default: false
    t.boolean  "is_instructor",          default: true
    t.boolean  "instructor_request",     default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["girl_match_skill_id"], name: "index_users_on_girl_match_skill_id"
  add_index "users", ["referred_user_id"], name: "index_users_on_referred_user_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  add_index "users", ["skill_id"], name: "index_users_on_skill_id"

  create_table "votes", force: true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "voter_id"
    t.string   "voter_type"
    t.boolean  "vote_flag"
    t.string   "vote_scope"
    t.integer  "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
  add_index "votes", ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"

end
