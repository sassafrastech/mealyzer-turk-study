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

ActiveRecord::Schema.define(version: 20140915202435) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "match_answers", force: true do |t|
    t.integer  "meal_id"
    t.integer  "user_id"
    t.text     "food_groups"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "component_name"
    t.text     "food_groups_update"
    t.text     "explanation"
    t.boolean  "changed_answer"
    t.integer  "evaluating_id"
    t.integer  "impact"
    t.boolean  "food_groups_correct"
    t.boolean  "food_groups_update_correct"
    t.text     "food_groups_correct_all"
    t.text     "food_groups_update_correct_all"
    t.integer  "task_num"
    t.string   "task_type"
    t.integer  "num_ingredients"
    t.integer  "num_correct"
    t.integer  "num_correct_update"
  end

  add_index "match_answers", ["evaluating_id"], name: "index_match_answers_on_evaluating_id", using: :btree
  add_index "match_answers", ["meal_id"], name: "index_match_answers_on_meal_id", using: :btree
  add_index "match_answers", ["user_id"], name: "index_match_answers_on_user_id", using: :btree

  create_table "meals", force: true do |t|
    t.string   "name",               default: "Meal"
    t.text     "food_locations"
    t.text     "food_options"
    t.text     "food_nutrition"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.text     "food_components"
  end

  create_table "tag_answers", force: true do |t|
    t.integer  "user_id"
    t.integer  "meal_id"
    t.text     "food_locations"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_answers", ["meal_id"], name: "index_tag_answers_on_meal_id", using: :btree
  add_index "tag_answers", ["user_id"], name: "index_tag_answers_on_user_id", using: :btree

  create_table "turkee_imported_assignments", force: true do |t|
    t.string   "assignment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "turkee_task_id"
    t.string   "worker_id"
    t.integer  "result_id"
  end

  add_index "turkee_imported_assignments", ["assignment_id"], name: "index_turkee_imported_assignments_on_assignment_id", unique: true, using: :btree
  add_index "turkee_imported_assignments", ["turkee_task_id"], name: "index_turkee_imported_assignments_on_turkee_task_id", using: :btree

  create_table "turkee_studies", force: true do |t|
    t.integer  "turkee_task_id"
    t.text     "feedback"
    t.string   "gold_response"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "turkee_studies", ["turkee_task_id"], name: "index_turkee_studies_on_turkee_task_id", using: :btree

  create_table "turkee_tasks", force: true do |t|
    t.string   "hit_url"
    t.boolean  "sandbox"
    t.string   "task_type"
    t.text     "hit_title"
    t.text     "hit_description"
    t.string   "hit_id"
    t.decimal  "hit_reward",            precision: 10, scale: 2
    t.integer  "hit_num_assignments"
    t.integer  "hit_lifetime"
    t.string   "form_url"
    t.integer  "completed_assignments",                          default: 0
    t.boolean  "complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "hit_duration"
    t.integer  "expired"
  end

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "workerId"
    t.string   "assignmentId"
    t.string   "hitId"
    t.integer  "condition"
    t.integer  "num_tests",    default: 0
    t.string   "study_id"
  end

end
