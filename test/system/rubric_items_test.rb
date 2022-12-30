require "application_system_test_case"

class RubricItemsTest < ApplicationSystemTestCase
  setup do
    @rubric_item = rubric_items(:one)
  end

  test "visiting the index" do
    visit rubric_items_url
    assert_selector "h1", text: "Rubric Items"
  end

  test "creating a Rubric item" do
    visit rubric_items_url
    click_on "New Rubric Item"

    fill_in "Location", with: @rubric_item.location
    fill_in "Points", with: @rubric_item.points
    fill_in "Problem", with: @rubric_item.problem_id
    fill_in "Title", with: @rubric_item.title
    click_on "Create Rubric item"

    assert_text "Rubric item was successfully created"
    click_on "Back"
  end

  test "updating a Rubric item" do
    visit rubric_items_url
    click_on "Edit", match: :first

    fill_in "Location", with: @rubric_item.location
    fill_in "Points", with: @rubric_item.points
    fill_in "Problem", with: @rubric_item.problem_id
    fill_in "Title", with: @rubric_item.title
    click_on "Update Rubric item"

    assert_text "Rubric item was successfully updated"
    click_on "Back"
  end

  test "destroying a Rubric item" do
    visit rubric_items_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Rubric item was successfully destroyed"
  end
end
