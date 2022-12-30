require "application_system_test_case"

class AssignmentsTest < ApplicationSystemTestCase
  setup do
    @assignment = assignments(:one)
  end

  test "visiting the index" do
    visit assignments_url
    assert_selector "h1", text: "Assignments"
  end

  test "creating a Assignment" do
    visit assignments_url
    click_on "New Assignment"

    fill_in "Course", with: @assignment.course_id
    fill_in "Files Repo", with: @assignment.files_repo_id
    fill_in "Grade Category", with: @assignment.grade_category_id
    fill_in "Klass", with: @assignment.klass_id
    fill_in "Template Repo", with: @assignment.template_repo_id
    fill_in "Title", with: @assignment.title
    click_on "Create Assignment"

    assert_text "Assignment was successfully created"
    click_on "Back"
  end

  test "updating a Assignment" do
    visit assignments_url
    click_on "Edit", match: :first

    fill_in "Course", with: @assignment.course_id
    fill_in "Files Repo", with: @assignment.files_repo_id
    fill_in "Grade Category", with: @assignment.grade_category_id
    fill_in "Klass", with: @assignment.klass_id
    fill_in "Template Repo", with: @assignment.template_repo_id
    fill_in "Title", with: @assignment.title
    click_on "Update Assignment"

    assert_text "Assignment was successfully updated"
    click_on "Back"
  end

  test "destroying a Assignment" do
    visit assignments_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Assignment was successfully destroyed"
  end
end
