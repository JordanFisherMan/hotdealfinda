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

ActiveRecord::Schema.define(version: 2019_11_06_085402) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "slug", null: false
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "deals", force: :cascade do |t|
    t.string "deal_id", null: false
    t.string "image_url", null: false
    t.text "title", null: false
    t.text "highlights"
    t.string "price", null: false
    t.text "url", null: false
    t.date "expiry_date", null: false
    t.string "category"
    t.string "division", null: false
    t.integer "rating", null: false
    t.float "sort_price", null: false
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deal_id"], name: "index_deals_on_deal_id", unique: true
  end

end
