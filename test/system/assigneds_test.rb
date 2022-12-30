require "application_system_test_case"

class AssignedsTest < ApplicationSystemTestCase
  setup do
    @assigned = assigneds(:one)
  end

  test "visiting the index" do
    visit assigneds_url
    assert_selector "h1", text: "Assigneds"
  end

  test "creating a Assigned" do
    visit assigneds_url
    click_on "New Assigned"

    fill_in "Assignment", with: @assigned.assignment_id
    fill_in "Due Date", with: @assigned.due_date
    fill_in "Klass", with: @assigned.klass_id
    click_on "Create Assigned"

    assert_text "Assigned was successfully created"
    click_on "Back"
  end

  test "updating a Assigned" do
    visit assigneds_url
    click_on "Edit", match: :first

    fill_in "Assignment", with: @assigned.assignment_id
    fill_in "Due Date", with: @assigned.due_date
    fill_in "Klass", with: @assigned.klass_id
    click_on "Update Assigned"

    assert_text "Assigned was successfully updated"
    click_on "Back"
  end

  test "destroying a Assigned" do
    visit assigneds_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Assigned was successfully destroyed"
  end
end
