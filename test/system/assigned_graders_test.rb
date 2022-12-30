require "application_system_test_case"

class AssignedGradersTest < ApplicationSystemTestCase
  setup do
    @assigned_grader = assigned_graders(:one)
  end

  test "visiting the index" do
    visit assigned_graders_url
    assert_selector "h1", text: "Assigned Graders"
  end

  test "creating a Assigned grader" do
    visit assigned_graders_url
    click_on "New Assigned Grader"

    fill_in "Assigned", with: @assigned_grader.assigned_id
    fill_in "User", with: @assigned_grader.user_id
    click_on "Create Assigned grader"

    assert_text "Assigned grader was successfully created"
    click_on "Back"
  end

  test "updating a Assigned grader" do
    visit assigned_graders_url
    click_on "Edit", match: :first

    fill_in "Assigned", with: @assigned_grader.assigned_id
    fill_in "User", with: @assigned_grader.user_id
    click_on "Update Assigned grader"

    assert_text "Assigned grader was successfully updated"
    click_on "Back"
  end

  test "destroying a Assigned grader" do
    visit assigned_graders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Assigned grader was successfully destroyed"
  end
end
