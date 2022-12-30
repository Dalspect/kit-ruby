require 'test_helper'

class GradeCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @grade_category = grade_categories(:one)
  end

  test "should get index" do
    get grade_categories_url
    assert_response :success
  end

  test "should get new" do
    get new_grade_category_url
    assert_response :success
  end

  test "should create grade_category" do
    assert_difference('GradeCategory.count') do
      post grade_categories_url, params: { grade_category: { course_id: @grade_category.course_id, klass_id: @grade_category.klass_id, title: @grade_category.title, weight: @grade_category.weight } }
    end

    assert_redirected_to grade_category_url(GradeCategory.last)
  end

  test "should show grade_category" do
    get grade_category_url(@grade_category)
    assert_response :success
  end

  test "should get edit" do
    get edit_grade_category_url(@grade_category)
    assert_response :success
  end

  test "should update grade_category" do
    patch grade_category_url(@grade_category), params: { grade_category: { course_id: @grade_category.course_id, klass_id: @grade_category.klass_id, title: @grade_category.title, weight: @grade_category.weight } }
    assert_redirected_to grade_category_url(@grade_category)
  end

  test "should destroy grade_category" do
    assert_difference('GradeCategory.count', -1) do
      delete grade_category_url(@grade_category)
    end

    assert_redirected_to grade_categories_url
  end
end
