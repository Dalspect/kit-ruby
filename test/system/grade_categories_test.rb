require "application_system_test_case"

class GradeCategoriesTest < ApplicationSystemTestCase
  setup do
    @grade_category = grade_categories(:one)
  end

  test "visiting the index" do
    visit grade_categories_url
    assert_selector "h1", text: "Grade Categories"
  end

  test "creating a Grade category" do
    visit grade_categories_url
    click_on "New Grade Category"

    fill_in "Course", with: @grade_category.course_id
    fill_in "Klass", with: @grade_category.klass_id
    fill_in "Title", with: @grade_category.title
    fill_in "Weight", with: @grade_category.weight
    click_on "Create Grade category"

    assert_text "Grade category was successfully created"
    click_on "Back"
  end

  test "updating a Grade category" do
    visit grade_categories_url
    click_on "Edit", match: :first

    fill_in "Course", with: @grade_category.course_id
    fill_in "Klass", with: @grade_category.klass_id
    fill_in "Title", with: @grade_category.title
    fill_in "Weight", with: @grade_category.weight
    click_on "Update Grade category"

    assert_text "Grade category was successfully updated"
    click_on "Back"
  end

  test "destroying a Grade category" do
    visit grade_categories_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Grade category was successfully destroyed"
  end
end
