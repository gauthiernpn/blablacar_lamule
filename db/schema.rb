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

ActiveRecord::Schema.define(version: 20140630081928) do

  create_table "car_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_makers", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "car_models", force: true do |t|
    t.string   "name"
    t.integer  "car_maker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cars", force: true do |t|
    t.string   "car_image"
    t.string   "image_status"
    t.integer  "level_of_comfort"
    t.integer  "number_of_seats"
    t.integer  "user_id"
    t.integer  "color_id"
    t.integer  "car_model_id"
    t.integer  "car_maker_id"
    t.integer  "car_category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "colors", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "name"
    t.string   "country_code"
    t.string   "country_format"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "default_notifications", force: true do |t|
    t.string   "name"
    t.string   "text"
    t.string   "medium"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", force: true do |t|
    t.string   "name"
    t.string   "friend_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.text     "address"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "zipcode"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "countrycode"
    t.string   "nearbyplace"
    t.string   "phone"
    t.integer  "sequence"
    t.integer  "ride_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ride_type"
  end

  create_table "message_threads", force: true do |t|
    t.integer  "user_id"
    t.integer  "communicator_id"
    t.integer  "ride_id"
    t.integer  "status",          default: 0
    t.boolean  "unread",          default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "messages", force: true do |t|
    t.text     "body"
    t.integer  "message_thread_id"
    t.integer  "message_type"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", force: true do |t|
    t.string   "name"
    t.string   "text"
    t.string   "medium"
    t.boolean  "status",     default: true
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phone_numbers", force: true do |t|
    t.string   "body"
    t.boolean  "verified_no"
    t.integer  "verification_code"
    t.integer  "public_status"
    t.integer  "user_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preferences", force: true do |t|
    t.integer  "chattiness", default: 1
    t.integer  "music",      default: 1
    t.integer  "smoking",    default: 1
    t.integer  "pets",       default: 1
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.text     "mini_bio"
    t.text     "address_1"
    t.text     "address_2"
    t.string   "displayed_as"
    t.string   "photo"
    t.string   "postcode"
    t.string   "city"
    t.integer  "country_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ride_weeks", force: true do |t|
    t.boolean  "sat"
    t.boolean  "sun"
    t.boolean  "mon"
    t.boolean  "tue"
    t.boolean  "wed"
    t.boolean  "thu"
    t.boolean  "fri"
    t.integer  "ride_id"
    t.integer  "date_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rides", force: true do |t|
    t.text     "general_details"
    t.text     "specific_details"
    t.integer  "number_of_seats"
    t.string   "max_luggage_size"
    t.integer  "leaving_delay"
    t.integer  "detour_preferences"
    t.boolean  "is_recurring_trip"
    t.boolean  "is_details_same"
    t.boolean  "is_round_trip",      default: true
    t.datetime "departure_date"
    t.datetime "return_date"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "routing_required",   default: true
    t.integer  "car_id"
    t.integer  "full_completed",     default: 0
    t.string   "total_distance"
    t.string   "total_time"
    t.float    "total_price"
    t.integer  "views_count",        default: 0
  end

  create_table "routes", force: true do |t|
    t.float    "price"
    t.integer  "source_id"
    t.integer  "destination_id"
    t.integer  "ride_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unsubscribe_reasons", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "unsubscribes", force: true do |t|
    t.text     "comment"
    t.boolean  "recommend"
    t.integer  "user_id"
    t.integer  "unsubscribe_reason_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
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
    t.string   "name"
    t.string   "provider"
    t.string   "uid"
    t.string   "gender"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "birth_year"
    t.boolean  "email_verified"
    t.boolean  "receive_updates"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
