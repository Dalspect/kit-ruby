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

ActiveRecord::Schema.define(version: 2020_03_27_191017) do

  create_table "assigned_graders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "assigned_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_id"], name: "index_assigned_graders_on_assigned_id"
    t.index ["user_id"], name: "index_assigned_graders_on_user_id"
  end

  create_table "assigneds", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "assignment_id"
    t.integer "klass_id"
    t.datetime "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allow_late_submissions"
    t.integer "max_contributors"
    t.decimal "max_points_override", precision: 16, scale: 4
    t.decimal "point_value_scale", precision: 16, scale: 4
    t.integer "repo_id"
    t.boolean "limit_resubmissions"
    t.integer "resubmission_limit"
    t.integer "allow_resubmissions"
    t.boolean "hide_grades"
    t.index ["assignment_id"], name: "index_assigneds_on_assignment_id"
    t.index ["klass_id"], name: "index_assigneds_on_klass_id"
    t.index ["repo_id"], name: "index_assigneds_on_repo_id"
  end

  create_table "assignments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "klass_id"
    t.integer "course_id"
    t.integer "grade_category_id"
    t.integer "files_repo_id"
    t.integer "template_repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "assignment_type"
    t.string "permitted_filetypes"
    t.text "description"
    t.integer "file_limit", default: 1
    t.integer "file_or_link"
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["files_repo_id"], name: "index_assignments_on_files_repo_id"
    t.index ["grade_category_id"], name: "index_assignments_on_grade_category_id"
    t.index ["klass_id"], name: "index_assignments_on_klass_id"
    t.index ["template_repo_id"], name: "index_assignments_on_template_repo_id"
  end

  create_table "checked_rubric_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "rubric_item_id"
    t.integer "graded_problem_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["graded_problem_id"], name: "index_checked_rubric_items_on_graded_problem_id"
    t.index ["rubric_item_id"], name: "index_checked_rubric_items_on_rubric_item_id"
  end

  create_table "contributor_invites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_contributor_invites_on_submission_id"
    t.index ["user_id"], name: "index_contributor_invites_on_user_id"
  end

  create_table "contributors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "feedback_seen", default: false
    t.index ["submission_id"], name: "index_contributors_on_submission_id"
    t.index ["user_id"], name: "index_contributors_on_user_id"
  end

  create_table "courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "course_code"
    t.integer "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.boolean "active", default: true
    t.index ["department_id"], name: "index_courses_on_department_id"
    t.index ["repo_id"], name: "index_courses_on_repo_id"
  end

  create_table "department_professors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "department_id"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_department_professors_on_department_id"
    t.index ["user_id"], name: "index_department_professors_on_user_id"
  end

  create_table "departments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.bigint "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["repo_id"], name: "index_departments_on_repo_id"
  end

  create_table "extensions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.boolean "allow_late_submissions"
    t.datetime "new_deadline"
    t.boolean "use_deadline_as_due_date"
    t.boolean "limit_resubmissions"
    t.integer "resubmission_limit"
    t.integer "allow_resubmissions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "assigned_id"
    t.index ["assigned_id"], name: "index_extensions_on_assigned_id"
    t.index ["user_id"], name: "index_extensions_on_user_id"
  end

  create_table "grade_categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "klass_id"
    t.integer "course_id"
    t.decimal "weight", precision: 16, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_grade_categories_on_course_id"
    t.index ["klass_id"], name: "index_grade_categories_on_klass_id"
  end

  create_table "graded_problems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "problem_id"
    t.integer "submission_id"
    t.text "comments"
    t.decimal "point_adjustment", precision: 16, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "grader_id"
    t.index ["problem_id"], name: "index_graded_problems_on_problem_id"
    t.index ["submission_id"], name: "index_graded_problems_on_submission_id"
  end

  create_table "graders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "klass_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notify_grader_assigned", default: false
    t.index ["klass_id"], name: "index_graders_on_klass_id"
    t.index ["user_id"], name: "index_graders_on_user_id"
  end

  create_table "klasses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "course_id"
    t.integer "repo_id"
    t.string "semester"
    t.integer "section"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_klasses_on_course_id"
    t.index ["repo_id"], name: "index_klasses_on_repo_id"
  end

  create_table "notify_grader_new_submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "assigned_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_id"], name: "index_notify_grader_new_submissions_on_assigned_id"
    t.index ["user_id"], name: "index_notify_grader_new_submissions_on_user_id"
  end

  create_table "notify_grader_regrade_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "assigned_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assigned_id"], name: "index_notify_grader_regrade_requests_on_assigned_id"
    t.index ["user_id"], name: "index_notify_grader_regrade_requests_on_user_id"
  end

  create_table "past_contributors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "submission_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_past_contributors_on_submission_id"
    t.index ["user_id"], name: "index_past_contributors_on_user_id"
  end

  create_table "problems", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "assignment_id"
    t.string "title"
    t.decimal "points", precision: 16, scale: 4
    t.integer "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "grader_notes"
    t.index ["assignment_id"], name: "index_problems_on_assignment_id"
  end

  create_table "professors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "klass_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["klass_id"], name: "index_professors_on_klass_id"
    t.index ["user_id"], name: "index_professors_on_user_id"
  end

  create_table "regrade_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "submission_id"
    t.text "reason"
    t.boolean "closed", default: false
    t.text "response"
    t.bigint "requested_by_id"
    t.bigint "closed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["closed_by_id"], name: "index_regrade_requests_on_closed_by_id"
    t.index ["requested_by_id"], name: "index_regrade_requests_on_requested_by_id"
    t.index ["submission_id"], name: "index_regrade_requests_on_submission_id"
  end

  create_table "repos", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reusable_comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "problem_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_reusable_comments_on_problem_id"
  end

  create_table "rubric_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "problem_id"
    t.string "title"
    t.decimal "points", precision: 16, scale: 4
    t.integer "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["problem_id"], name: "index_rubric_items_on_problem_id"
  end

  create_table "ssh_keys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "key"
    t.integer "user_id"
    t.string "label"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ssh_keys_on_user_id"
  end

  create_table "students", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "klass_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "notify_assignment_assigned", default: false
    t.boolean "notify_graded", default: false
    t.boolean "notify_contributor_invite", default: false
    t.boolean "notify_extension", default: false
    t.boolean "notify_regrade_response"
    t.index ["klass_id"], name: "index_students_on_klass_id"
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "submissions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "assigned_id"
    t.integer "repo_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "turned_in"
    t.datetime "turned_in_time"
    t.decimal "point_adjustment", precision: 16, scale: 4
    t.decimal "percent_modifier", precision: 16, scale: 4
    t.boolean "point_override"
    t.boolean "blank"
    t.boolean "professor_uploaded"
    t.text "overall_comments"
    t.decimal "cached_grade", precision: 16, scale: 4
    t.boolean "notified_graded", default: false
    t.boolean "hide_rubric", default: false
    t.boolean "force_allow_resubmit", default: false
    t.index ["assigned_id"], name: "index_submissions_on_assigned_id"
    t.index ["repo_id"], name: "index_submissions_on_repo_id"
  end

  create_table "user_invites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.string "token_digest"
    t.boolean "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_klass_invites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "klass_id"
    t.integer "user_invite_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["klass_id"], name: "index_user_klass_invites_on_klass_id"
    t.index ["user_invite_id"], name: "index_user_klass_invites_on_user_invite_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email"
    t.boolean "admin"
    t.string "first_name"
    t.string "last_name"
    t.string "preferred_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "reset_digest"
    t.datetime "reset_expires"
    t.boolean "set_up", default: false
    t.boolean "disabled", default: false
  end

  add_foreign_key "courses", "departments"
  add_foreign_key "department_professors", "departments"
  add_foreign_key "department_professors", "users"
  add_foreign_key "departments", "repos"
  add_foreign_key "notify_grader_new_submissions", "assigneds"
  add_foreign_key "notify_grader_new_submissions", "users"
  add_foreign_key "notify_grader_regrade_requests", "assigneds"
  add_foreign_key "notify_grader_regrade_requests", "users"
  add_foreign_key "regrade_requests", "submissions"
  add_foreign_key "regrade_requests", "users", column: "closed_by_id"
  add_foreign_key "regrade_requests", "users", column: "requested_by_id"
  add_foreign_key "reusable_comments", "problems"
end
