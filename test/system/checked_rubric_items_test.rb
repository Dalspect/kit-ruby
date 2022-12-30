require "application_system_test_case"

class CheckedRubricItemsTest < ApplicationSystemTestCase
  setup do
    @checked_rubric_item = checked_rubric_items(:one)
  end

  test "visiting the index" do
    visit checked_rubric_items_url
    assert_selector "h1", text: "Checked Rubric Items"
  end

  test "creating a Checked rubric item" do
    visit checked_rubric_items_url
    click_on "New Checked Rubric Item"

    fill_in "Graded Problem", with: @checked_rubric_item.graded_problem_id
    fill_in "Rubric Item", with: @checked_rubric_item.rubric_item_id
    click_on "Create Checked rubric item"

    assert_text "Checked rubric item was successfully created"
    click_on "Back"
  end

  test "updating a Checked rubric item" do
    visit checked_rubric_items_url
    click_on "Edit", match: :first

    fill_in "Graded Problem", with: @checked_rubric_item.graded_problem_id
    fill_in "Rubric Item", with: @checked_rubric_item.rubric_item_id
    click_on "Update Checked rubric item"

    assert_text "Checked rubric item was successfully updated"
    click_on "Back"
  end

  test "destroying a Checked rubric item" do
    visit checked_rubric_items_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Checked rubric item was successfully destroyed"
  end
end
