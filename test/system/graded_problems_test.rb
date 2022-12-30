require "application_system_test_case"

class GradedProblemsTest < ApplicationSystemTestCase
  setup do
    @graded_problem = graded_problems(:one)
  end

  test "visiting the index" do
    visit graded_problems_url
    assert_selector "h1", text: "Graded Problems"
  end

  test "creating a Graded problem" do
    visit graded_problems_url
    click_on "New Graded Problem"

    fill_in "Comments", with: @graded_problem.comments
    fill_in "Grader", with: @graded_problem.grader_id
    fill_in "Point Adjustment", with: @graded_problem.point_adjustment
    fill_in "Problem", with: @graded_problem.problem_id
    fill_in "Submission", with: @graded_problem.submission_id
    click_on "Create Graded problem"

    assert_text "Graded problem was successfully created"
    click_on "Back"
  end

  test "updating a Graded problem" do
    visit graded_problems_url
    click_on "Edit", match: :first

    fill_in "Comments", with: @graded_problem.comments
    fill_in "Grader", with: @graded_problem.grader_id
    fill_in "Point Adjustment", with: @graded_problem.point_adjustment
    fill_in "Problem", with: @graded_problem.problem_id
    fill_in "Submission", with: @graded_problem.submission_id
    click_on "Update Graded problem"

    assert_text "Graded problem was successfully updated"
    click_on "Back"
  end

  test "destroying a Graded problem" do
    visit graded_problems_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Graded problem was successfully destroyed"
  end
end
