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

ActiveRecord::Schema.define(version: 2018_07_04_142802) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "encrypted_ecobee_pin"
    t.string "encrypted_ecobee_pin_iv"
    t.string "encrypted_access_token"
    t.string "encrypted_access_token_iv"
    t.string "encrypted_refresh_token"
    t.string "encrypted_refresh_token_iv"
    t.string "encrypted_thermostat_id"
    t.string "encrypted_thermostat_id_iv"
    t.string "encrypted_thermostat_name"
    t.string "encrypted_thermostat_name_iv"
    t.boolean "connected"
    t.datetime "last_connected"
    t.datetime "last_disconnected"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "phone"
    t.string "code"
    t.datetime "last_status"
    t.integer "response_code"
  end

end
