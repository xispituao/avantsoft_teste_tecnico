# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_17_015856) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "circles", force: :cascade do |t|
    t.decimal "x_axis", precision: 10, scale: 2
    t.decimal "y_axis", precision: 10, scale: 2
    t.decimal "diameter", precision: 10, scale: 2
    t.bigint "frame_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frame_id"], name: "index_circles_on_frame_id"
  end

  create_table "frames", force: :cascade do |t|
    t.decimal "x_axis", precision: 10, scale: 2
    t.decimal "y_axis", precision: 10, scale: 2
    t.decimal "width", precision: 10, scale: 2
    t.decimal "height", precision: 10, scale: 2
    t.integer "total_circles", default: 0
    t.decimal "highest_circle_position", precision: 10, scale: 2
    t.decimal "rightmost_circle_position", precision: 10, scale: 2
    t.decimal "leftmost_circle_position", precision: 10, scale: 2
    t.decimal "lowest_circle_position", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "circles_count", default: 0, null: false
  end

  add_foreign_key "circles", "frames"
end
