require "application_system_test_case"

class GradersTest < ApplicationSystemTestCase
  setup do
    @grader = graders(:one)
  end

  test "visiting the index" do
    visit graders_url
    assert_selector "h1", text: "Graders"
  end

  test "creating a Grader" do
    visit graders_url
    click_on "New Grader"

    fill_in "Klass", with: @grader.klass_id
    fill_in "User", with: @grader.user_id
    click_on "Create Grader"

    assert_text "Grader was successfully created"
    click_on "Back"
  end

  test "updating a Grader" do
    visit graders_url
    click_on "Edit", match: :first

    fill_in "Klass", with: @grader.klass_id
    fill_in "User", with: @grader.user_id
    click_on "Update Grader"

    assert_text "Grader was successfully updated"
    click_on "Back"
  end

  test "destroying a Grader" do
    visit graders_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Grader was successfully destroyed"
  end
end
